class StripeService
  def self.create_customer(user)
    customer = Stripe::Customer.create({
      email: user.email,
      name: user.full_name,
      metadata: {
        user_id: user.id,
        user_role: user.user_role
      }
    })

    user.update(stripe_customer_id: customer.id)
    customer
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe Customer Creation Error: #{e.message}"
    nil
  end

  def self.create_checkout_session(user, plan)
    # Handle free plans without Stripe
    if plan.price == 0 || plan.stripe_price_id.blank?
      local_subscription = user.subscriptions.create!(
        plan: plan,
        status: :active,
        current_period_start: Time.current,
        current_period_end: plan.price == 0 ? 100.years.from_now : 1.month.from_now
      )
      
      return {
        subscription: local_subscription,
        checkout_url: nil
      }
    end

    # Ensure user has a Stripe customer ID for paid plans
    stripe_customer = user.stripe_customer_id.present? ?
                      Stripe::Customer.retrieve(user.stripe_customer_id) :
                      create_customer(user)

    return nil unless stripe_customer

    # Create Stripe Checkout session
    session = Stripe::Checkout::Session.create({
      customer: stripe_customer.id,
      payment_method_types: ['card'],
      line_items: [{
        price: plan.stripe_price_id,
        quantity: 1
      }],
      mode: 'subscription',
      success_url: "#{Rails.application.routes.url_helpers.payment_success_provider_subscriptions_url}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: Rails.application.routes.url_helpers.new_provider_subscription_url,
      metadata: {
        user_id: user.id,
        plan_id: plan.id
      },
      subscription_data: {
        trial_period_days: 14,
        metadata: {
          user_id: user.id,
          plan_id: plan.id
        }
      }
    })

    {
      subscription: nil,
      checkout_url: session.url,
      session_id: session.id
    }
  end

  def self.create_subscription(user, plan, payment_method_id = nil)
    # This method is kept for backward compatibility
    # but now redirects to checkout session creation
    create_checkout_session(user, plan)
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe Subscription Creation Error: #{e.message}"
    nil
  end

  def self.cancel_subscription(subscription)
    return false unless subscription.stripe_subscription_id

    stripe_subscription = Stripe::Subscription.update(
      subscription.stripe_subscription_id,
      { cancel_at_period_end: true }
    )

    subscription.update!(
      cancel_at_period_end: true,
      status: map_stripe_status(stripe_subscription.status)
    )

    true
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe Subscription Cancellation Error: #{e.message}"
    false
  end

  def self.update_subscription_from_stripe(stripe_subscription)
    subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription.id)
    return unless subscription

    subscription.update!(
      status: map_stripe_status(stripe_subscription.status),
      current_period_start: Time.at(stripe_subscription.current_period_start),
      current_period_end: Time.at(stripe_subscription.current_period_end),
      cancel_at_period_end: stripe_subscription.cancel_at_period_end
    )
  end

  def self.handle_invoice_payment_succeeded(invoice)
    subscription = Subscription.find_by(stripe_subscription_id: invoice.subscription)
    return unless subscription

    # Update subscription status
    stripe_subscription = Stripe::Subscription.retrieve(invoice.subscription)
    update_subscription_from_stripe(stripe_subscription)
  end

  def self.handle_invoice_payment_failed(invoice)
    subscription = Subscription.find_by(stripe_subscription_id: invoice.subscription)
    return unless subscription

    subscription.update!(status: :past_due)
  end

  private

  def self.map_stripe_status(stripe_status)
    case stripe_status
    when "active" then :active
    when "trialing" then :trialing
    when "past_due" then :past_due
    when "canceled" then :canceled
    when "unpaid" then :unpaid
    when "incomplete" then :incomplete
    else :incomplete
    end
  end
end

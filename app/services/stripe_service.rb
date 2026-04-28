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
      payment_method_types: [ "card" ],
      line_items: [ {
        price: plan.stripe_price_id,
        quantity: 1
      } ],
      mode: "subscription",
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

  def self.create_booking_checkout(booking, charge_deposit_only: false)
    user = booking.customer
    service = booking.service

    stripe_customer = user.stripe_customer_id.present? ?
                      Stripe::Customer.retrieve(user.stripe_customer_id) :
                      create_customer(user)

    return nil unless stripe_customer

    # Determine amount to charge
    amount_to_charge = if charge_deposit_only && booking.deposit_amount.present? && booking.deposit_amount > 0
      booking.deposit_amount
    else
      booking.total_price
    end

    product_name = if charge_deposit_only && booking.deposit_amount.present?
      "#{service.title} (Deposit)"
    else
      service.title
    end

    amount_cents = (amount_to_charge * 100).to_i
    platform_fee_cents = (amount_cents * PLATFORM_COMMISSION_RATE).to_i
    provider = service.provider

    payment_intent_data = {
      metadata: {
        booking_id: booking.id,
        payment_type: charge_deposit_only ? "deposit" : "full"
      }
    }

    # If provider has Stripe Connect set up, use payment split
    if provider.stripe_connect_id.present? && provider.stripe_connect_charges_enabled?
      payment_intent_data[:application_fee_amount] = platform_fee_cents
      payment_intent_data[:transfer_data] = { destination: provider.stripe_connect_id }
    end

    session = Stripe::Checkout::Session.create({
      customer: stripe_customer.id,
      payment_method_types: ["card"],
      line_items: [{
        price_data: {
          currency: "usd",
          product_data: {
            name: product_name,
            description: "Service by #{provider.display_name}"
          },
          unit_amount: amount_cents
        },
        quantity: 1
      }],
      mode: "payment",
      success_url: "#{Rails.application.routes.url_helpers.booking_payment_success_url(booking)}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: Rails.application.routes.url_helpers.service_url(service),
      payment_intent_data: payment_intent_data,
      metadata: {
        booking_id: booking.id,
        user_id: user.id,
        service_id: service.id,
        payment_type: charge_deposit_only ? "deposit" : "full"
      }
    })

    booking.update(
      platform_fee_cents: platform_fee_cents,
      provider_payout_cents: amount_cents - platform_fee_cents
    )

    booking.update(stripe_checkout_session_id: session.id)

    { checkout_url: session.url, session_id: session.id }
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe Booking Checkout Error: #{e.message}"
    nil
  end

  # Platform commission: 10% of booking
  PLATFORM_COMMISSION_RATE = 0.10

  def self.create_gift_card_checkout(gift_card, buyer)
    stripe_customer = buyer.stripe_customer_id.present? ?
                      Stripe::Customer.retrieve(buyer.stripe_customer_id) :
                      create_customer(buyer)
    return nil unless stripe_customer

    amount_cents = (gift_card.amount.to_f * 100).to_i

    session = Stripe::Checkout::Session.create({
      customer: stripe_customer.id,
      payment_method_types: [ "card" ],
      line_items: [ {
        price_data: {
          currency: "usd",
          product_data: {
            name: "Gift Card — $#{gift_card.amount}",
            description: gift_card.recipient_name.present? ? "For #{gift_card.recipient_name}" : "Radius gift card"
          },
          unit_amount: amount_cents
        },
        quantity: 1
      } ],
      mode: "payment",
      success_url: "#{Rails.application.routes.url_helpers.payment_success_gift_card_url(gift_card)}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: Rails.application.routes.url_helpers.gift_cards_url,
      metadata: {
        gift_card_id: gift_card.id,
        buyer_id: buyer.id,
        type: "gift_card"
      }
    })

    { checkout_url: session.url, session_id: session.id }
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe Gift Card Checkout Error: #{e.message}"
    nil
  end

  def self.refund_booking(booking, reason: "requested_by_customer")
    return { error: "No payment to refund" } unless booking.stripe_payment_intent_id.present?

    refund = Stripe::Refund.create(
      payment_intent: booking.stripe_payment_intent_id,
      reason: reason,
      metadata: { booking_id: booking.id }
    )
    { refund_id: refund.id, amount: refund.amount.to_f / 100.0 }
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe Refund Error: #{e.message}"
    { error: e.message }
  end

  def self.create_connect_account(user)
    return user.stripe_connect_id if user.stripe_connect_id.present?
    account = Stripe::Account.create({
      type: "express",
      country: "US",
      email: user.email,
      capabilities: {
        card_payments: { requested: true },
        transfers: { requested: true }
      },
      business_type: "individual",
      metadata: { user_id: user.id }
    })
    user.update(stripe_connect_id: account.id)
    account.id
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe Connect create error: #{e.message}"
    nil
  end

  def self.connect_onboarding_link(user, return_url:, refresh_url:)
    account_id = create_connect_account(user)
    return nil unless account_id

    link = Stripe::AccountLink.create({
      account: account_id,
      refresh_url: refresh_url,
      return_url: return_url,
      type: "account_onboarding"
    })
    link.url
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe Connect onboarding link error: #{e.message}"
    nil
  end

  def self.refresh_connect_status(user)
    return false unless user.stripe_connect_id
    account = Stripe::Account.retrieve(user.stripe_connect_id)
    user.update(
      stripe_connect_onboarded: account.details_submitted,
      stripe_connect_charges_enabled: account.charges_enabled,
      stripe_connect_payouts_enabled: account.payouts_enabled
    )
    true
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe Connect status refresh error: #{e.message}"
    false
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

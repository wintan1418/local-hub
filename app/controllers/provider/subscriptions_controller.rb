class Provider::SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_provider
  before_action :check_existing_subscription, only: [ :new, :create ]

  def index
    @subscription = current_user.subscription
    @plans = Plan.active.ordered
  end

  def new
    @plans = Plan.active.ordered
    @selected_plan = Plan.find_by(id: params[:plan_id]) || @plans.first
  end

  def create
    @plan = Plan.find(params[:plan_id])

    # Use StripeService for all plan types (it handles free plans internally)
    result = StripeService.create_checkout_session(current_user, @plan)

    if result
      if result[:checkout_url]
        # Redirect to Stripe Checkout for paid plans
        redirect_to result[:checkout_url], allow_other_host: true
      elsif result[:subscription]
        # Free plan activated
        redirect_to provider_dashboard_path, notice: "Free subscription activated successfully!"
      end
    else
      @plans = Plan.active.ordered
      flash.now[:alert] = "Failed to create subscription. Please try again."
      render :new, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Subscription Creation Error: #{e.message}"
    @plans = Plan.active.ordered
    flash.now[:alert] = "Failed to create subscription. Please try again."
    render :new, status: :unprocessable_entity
  end

  def cancel
    @subscription = current_user.subscription

    if @subscription && StripeService.cancel_subscription(@subscription)
      redirect_to provider_subscriptions_path, notice: "Subscription will be canceled at the end of the billing period."
    else
      redirect_to provider_subscriptions_path, alert: "Unable to cancel subscription."
    end
  end

  def confirm_payment
    @subscription = Subscription.find(params[:subscription_id])
    @client_secret = params[:client_secret]
    @publishable_key = Rails.application.config.stripe[:publishable_key]
  end

  def success
    @subscription = current_user.subscriptions.find(params[:subscription_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to provider_subscriptions_path, alert: "Subscription not found."
  end

  def payment_success
    session_id = params[:session_id]

    if session_id
      # Retrieve the checkout session from Stripe
      session = Stripe::Checkout::Session.retrieve(session_id)

      # Check if subscription was actually created
      if session.subscription
        subscription = Stripe::Subscription.retrieve(session.subscription)

        # Find the plan and user from metadata
        plan = Plan.find(session.metadata.plan_id)
        user = User.find(session.metadata.user_id)

        # Create local subscription record
        local_subscription = user.subscriptions.create!(
          plan: plan,
          stripe_subscription_id: subscription.id,
          stripe_customer_id: session.customer,
          status: subscription.status&.to_sym || :active,
          current_period_start: Time.current,
          current_period_end: 1.month.from_now
        )

        redirect_to success_provider_subscriptions_path(subscription_id: local_subscription.id)
      else
        Rails.logger.error "No subscription found in session: #{session_id}"
        redirect_to provider_subscriptions_path, alert: "No subscription was created. Please try again."
      end
    else
      redirect_to provider_subscriptions_path, alert: "Invalid payment session."
    end
  rescue => e
    Rails.logger.error "Payment Success Error: #{e.message}"
    redirect_to provider_subscriptions_path, alert: "There was an error processing your payment. Please contact support."
  end

  private

  def ensure_provider
    redirect_to root_path, alert: "Access denied." unless current_user.provider?
  end

  def check_existing_subscription
    if current_user.has_active_subscription?
      redirect_to provider_subscriptions_path, alert: "You already have an active subscription."
    end
  end
end

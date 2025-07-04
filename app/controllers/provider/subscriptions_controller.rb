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

    if @plan.price == 0
      # Handle free plan locally
      @subscription = current_user.subscriptions.build(
        plan: @plan,
        status: :active,
        current_period_start: Time.current,
        current_period_end: 100.years.from_now
      )

      if @subscription.save
        redirect_to provider_dashboard_path, notice: "Free subscription activated successfully!"
      else
        @plans = Plan.active.ordered
        render :new, status: :unprocessable_entity
      end
    else
      # Handle paid plans with Stripe
      result = StripeService.create_subscription(current_user, @plan, params[:payment_method_id])

      if result && result[:subscription]
        if result[:client_secret]
          # Payment required - redirect to confirmation page
          redirect_to confirm_payment_provider_subscriptions_path(
            subscription_id: result[:subscription].id,
            client_secret: result[:client_secret]
          )
        else
          # Trial started successfully
          redirect_to provider_dashboard_path, notice: "Subscription created successfully! Your 14-day trial has started."
        end
      else
        @plans = Plan.active.ordered
        flash.now[:alert] = "Failed to create subscription. Please try again."
        render :new, status: :unprocessable_entity
      end
    end
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

  def payment_success
    @subscription = Subscription.find(params[:subscription_id])
    redirect_to provider_dashboard_path, notice: "Payment successful! Your subscription is now active."
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

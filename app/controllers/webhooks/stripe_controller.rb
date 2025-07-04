class Webhooks::StripeController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_stripe_signature

  def create
    case @event.type
    when 'invoice.payment_succeeded'
      StripeService.handle_invoice_payment_succeeded(@event.data.object)
    when 'invoice.payment_failed'
      StripeService.handle_invoice_payment_failed(@event.data.object)
    when 'customer.subscription.updated'
      StripeService.update_subscription_from_stripe(@event.data.object)
    when 'customer.subscription.deleted'
      subscription = Subscription.find_by(stripe_subscription_id: @event.data.object.id)
      subscription&.update!(status: :canceled)
    else
      Rails.logger.info "Unhandled Stripe event: #{@event.type}"
    end

    render json: { status: 'success' }
  end

  private

  def verify_stripe_signature
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET'] || 'whsec_test_secret'

    begin
      @event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError
      render json: { error: 'Invalid payload' }, status: 400
      return
    rescue Stripe::SignatureVerificationError
      render json: { error: 'Invalid signature' }, status: 400
      return
    end
  end
end
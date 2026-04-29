class Webhooks::StripeController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_stripe_signature

  def create
    obj = @event.data.object

    case @event.type
    when "invoice.payment_succeeded"
      StripeService.handle_invoice_payment_succeeded(obj)
    when "invoice.payment_failed"
      StripeService.handle_invoice_payment_failed(obj)
      notify_failed_invoice(obj)
    when "customer.subscription.updated"
      StripeService.update_subscription_from_stripe(obj)
    when "customer.subscription.deleted"
      Subscription.find_by(stripe_subscription_id: obj.id)&.update!(status: :canceled)

    when "checkout.session.completed"
      handle_checkout_completed(obj)

    when "payment_intent.succeeded"
      handle_payment_intent_succeeded(obj)

    when "payment_intent.payment_failed"
      handle_payment_intent_failed(obj)

    when "charge.refunded"
      handle_charge_refunded(obj)

    when "charge.dispute.created", "charge.dispute.funds_withdrawn"
      handle_chargeback(obj)

    when "account.updated"
      handle_connect_account_updated(obj)

    else
      Rails.logger.info "Unhandled Stripe event: #{@event.type}"
    end

    render json: { status: "ok" }
  rescue => e
    Rails.logger.error "Stripe webhook handler error (#{@event&.type}): #{e.class} #{e.message}"
    Rails.logger.error e.backtrace.first(10).join("\n")
    # Return 200 so Stripe doesn't retry forever on bugs we already logged.
    render json: { status: "logged" }
  end

  private

  # checkout.session.completed
  # Confirm the matching booking / gift card / subscription based on metadata.
  def handle_checkout_completed(session)
    type = (session.metadata && session.metadata["type"]) || infer_session_type(session)

    case type
    when "gift_card"
      gc_id = session.metadata && session.metadata["gift_card_id"]
      gift_card = gc_id && GiftCard.find_by(id: gc_id)
      if gift_card&.pending?
        gift_card.update(status: :active)
        if gift_card.recipient_email.present?
          GiftCardMailer.recipient_notification(gift_card).deliver_later
        end
      end

    else
      # Booking checkout (default for older sessions without explicit type)
      booking_id = session.metadata && session.metadata["booking_id"]
      booking = booking_id && Booking.find_by(id: booking_id)
      if booking && !booking.paid?
        booking.update(
          paid: true,
          stripe_payment_intent_id: session.payment_intent,
          stripe_checkout_session_id: session.id
        )
        if Notification.respond_to?(:create_for_booking)
          Notification.create_for_booking(booking, :updated, "Payment received — booking confirmed.")
        end
      end
    end
  end

  def infer_session_type(session)
    md = session.metadata || {}
    return "gift_card" if md["gift_card_id"].present?
    return "booking"   if md["booking_id"].present?
    "unknown"
  end

  def handle_payment_intent_succeeded(intent)
    booking = Booking.find_by(stripe_payment_intent_id: intent.id)
    return unless booking
    booking.update(paid: true) unless booking.paid?
  end

  def handle_payment_intent_failed(intent)
    booking = Booking.find_by(stripe_payment_intent_id: intent.id)
    return unless booking
    booking.update(paid: false)
    msg = intent.last_payment_error&.message || "Payment failed."
    if Notification.respond_to?(:create_for_booking)
      Notification.create_for_booking(booking, :updated, "Payment failed: #{msg}")
    end
  end

  def handle_charge_refunded(charge)
    booking = Booking.find_by(stripe_payment_intent_id: charge.payment_intent)
    return unless booking
    refunded_amount = (charge.amount_refunded.to_f / 100).round(2)
    booking.update(paid: false)
    if Notification.respond_to?(:create_for_booking)
      Notification.create_for_booking(booking, :updated, "Refund processed for $#{refunded_amount}.")
    end

    dispute = booking.dispute
    if dispute && !dispute.refunded? && !dispute.resolved?
      dispute.update(status: :refunded, refund_amount: refunded_amount, resolved_at: Time.current)
    end
  end

  def handle_chargeback(dispute_obj)
    charge_id = dispute_obj.charge
    return unless charge_id

    begin
      charge = Stripe::Charge.retrieve(charge_id)
      booking = Booking.find_by(stripe_payment_intent_id: charge.payment_intent)
      return unless booking

      reason = dispute_obj.reason || "unknown"
      unless booking.dispute
        booking.create_dispute(
          raised_by: booking.customer,
          reason: "Stripe chargeback (#{reason})",
          description: "Stripe chargeback opened by customer's bank. Status: #{dispute_obj.status}.",
          status: :open
        )
      end

      Rails.logger.warn "Stripe chargeback opened on booking #{booking.id} (reason: #{reason})"
    rescue Stripe::StripeError => e
      Rails.logger.error "Failed to retrieve charge for chargeback: #{e.message}"
    end
  end

  def handle_connect_account_updated(account)
    user = User.find_by(stripe_connect_id: account.id)
    return unless user
    user.update(
      stripe_connect_onboarded: account.details_submitted,
      stripe_connect_charges_enabled: account.charges_enabled,
      stripe_connect_payouts_enabled: account.payouts_enabled
    )
  end

  def notify_failed_invoice(invoice)
    sub = Subscription.find_by(stripe_subscription_id: invoice.subscription)
    return unless sub&.user
    Rails.logger.warn "Subscription invoice failed for user #{sub.user.id} (#{sub.plan&.name})"
  end

  def verify_stripe_signature
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = ENV["STRIPE_WEBHOOK_SECRET"] || "whsec_test_secret"

    @event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
  rescue JSON::ParserError
    render json: { error: "Invalid payload" }, status: 400
  rescue Stripe::SignatureVerificationError
    render json: { error: "Invalid signature" }, status: 400
  end
end

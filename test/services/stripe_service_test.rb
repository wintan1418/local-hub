require "test_helper"

class StripeServiceTest < ActiveSupport::TestCase
  setup do
    customer = User.create!(email: "stripe-customer@example.com", password: "password123", user_role: :customer)
    provider = User.create!(email: "stripe-provider@example.com", password: "password123", user_role: :provider)
    category = Category.create!(name: "Plumbing", slug: "plumbing")
    service = Service.create!(
      provider: provider,
      category: category,
      title: "Pipe repair",
      description: "Fix leaking pipe",
      price_type: :fixed,
      base_price: 75
    )
    @booking = Booking.create!(
      customer: customer,
      service: service,
      scheduled_at: 2.days.from_now,
      total_price: 75,
      stripe_checkout_session_id: "cs_test_123"
    )
  end

  test "checkout session must match booking metadata and amount" do
    session = checkout_session(
      amount_total: 7500,
      metadata: {
        "booking_id" => @booking.id.to_s,
        "user_id" => @booking.customer_id.to_s,
        "service_id" => @booking.service_id.to_s
      }
    )

    assert StripeService.checkout_session_paid_for_booking?(session, @booking)
  end

  test "checkout session with wrong amount is rejected" do
    session = checkout_session(
      amount_total: 100,
      metadata: {
        "booking_id" => @booking.id.to_s,
        "user_id" => @booking.customer_id.to_s,
        "service_id" => @booking.service_id.to_s
      }
    )

    assert_not StripeService.checkout_session_paid_for_booking?(session, @booking)
  end

  test "subscription checkout session must belong to current user and plan" do
    user = User.create!(
      email: "sub-user@example.com",
      password: "password123",
      user_role: :provider,
      stripe_customer_id: "cus_sub"
    )
    plan = Plan.create!(name: "Pro", price: 29, stripe_price_id: "price_pro")
    session = SubscriptionSession.new(
      mode: "subscription",
      subscription: "sub_123",
      customer: "cus_sub",
      metadata: {
        "user_id" => user.id.to_s,
        "plan_id" => plan.id.to_s
      }
    )

    assert StripeService.checkout_session_for_subscription?(session, user, plan)
  end

  private

  CheckoutSession = Struct.new(:id, :payment_status, :amount_total, :metadata, keyword_init: true)
  SubscriptionSession = Struct.new(:mode, :subscription, :customer, :metadata, keyword_init: true)

  def checkout_session(amount_total:, metadata:)
    CheckoutSession.new(
      id: "cs_test_123",
      payment_status: "paid",
      amount_total: amount_total,
      metadata: metadata
    )
  end
end

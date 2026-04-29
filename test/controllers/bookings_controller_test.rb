require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = User.create!(email: "booking-customer@example.com", password: "password123", user_role: :customer)
    @provider = User.create!(email: "booking-provider@example.com", password: "password123", user_role: :provider)
    @category = Category.create!(name: "Cleaning", slug: "cleaning")
    @service = Service.create!(
      provider: @provider,
      category: @category,
      title: "Deep clean",
      description: "Full home cleaning",
      price_type: :fixed,
      base_price: 125.50
    )
    sign_in @customer, scope: :user
  end

  test "create ignores customer supplied total price" do
    StripeService.stub(:create_booking_checkout, nil) do
      post service_bookings_path(@service), params: {
        booking: {
          scheduled_at: 2.days.from_now,
          total_price: 1.00
        }
      }
    end

    booking = Booking.order(:created_at).last
    assert_equal @service.base_price, booking.total_price
    assert_redirected_to booking_path(booking)
  end

  test "create uses selected package price from the same service" do
    package = @service.packages.create!(name: "Premium", price: 220, sort_order: 1)

    StripeService.stub(:create_booking_checkout, nil) do
      post service_bookings_path(@service), params: {
        booking: {
          scheduled_at: 2.days.from_now,
          service_package_id: package.id,
          total_price: 1.00
        }
      }
    end

    booking = Booking.order(:created_at).last
    assert_equal package.price, booking.total_price
    assert_equal package, booking.service_package
  end

  test "create rejects packages from other services" do
    other_service = Service.create!(
      provider: @provider,
      category: @category,
      title: "Window clean",
      description: "Windows",
      price_type: :fixed,
      base_price: 80
    )
    other_package = other_service.packages.create!(name: "Other", price: 60, sort_order: 1)

    assert_no_difference "Booking.count" do
      post service_bookings_path(@service), params: {
        booking: {
          scheduled_at: 2.days.from_now,
          service_package_id: other_package.id
        }
      }
    end

    assert_redirected_to service_path(@service)
  end

  test "payment success does not mark paid when stripe session verification fails" do
    booking = Booking.create!(
      customer: @customer,
      service: @service,
      scheduled_at: 2.days.from_now,
      total_price: 125.50,
      stripe_checkout_session_id: "cs_expected"
    )
    session = Struct.new(:id, :payment_status, :amount_total, :metadata, :payment_intent, keyword_init: true).new(
      id: "cs_expected",
      payment_status: "paid",
      amount_total: 100,
      metadata: {
        "booking_id" => booking.id.to_s,
        "user_id" => @customer.id.to_s,
        "service_id" => @service.id.to_s
      },
      payment_intent: "pi_test"
    )

    Stripe::Checkout::Session.stub(:retrieve, session) do
      get payment_success_booking_path(booking), params: { session_id: "cs_expected" }
    end

    assert_not booking.reload.paid?
    assert_redirected_to booking_path(booking)
  end
end

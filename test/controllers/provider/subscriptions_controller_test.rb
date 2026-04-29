require "test_helper"

class Provider::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = User.create!(
      email: "subscription-provider@example.com",
      password: "password123",
      user_role: :provider,
      stripe_customer_id: "cus_provider"
    )
    @plan = Plan.create!(name: "Professional", price: 29, stripe_price_id: "price_professional", active: true)
    sign_in @provider, scope: :user
  end

  test "payment success does not create subscription when checkout session belongs to another user" do
    session = CheckoutSession.new(
      mode: "subscription",
      subscription: "sub_123",
      customer: "cus_provider",
      metadata: {
        "user_id" => (@provider.id + 100).to_s,
        "plan_id" => @plan.id.to_s
      }
    )

    assert_no_difference "Subscription.count" do
      Stripe::Checkout::Session.stub(:retrieve, session) do
        get payment_success_provider_subscriptions_path, params: { session_id: "cs_bad" }
      end
    end

    assert_redirected_to provider_subscriptions_path
  end

  private

  CheckoutSession = Struct.new(:mode, :subscription, :customer, :metadata, keyword_init: true)
end

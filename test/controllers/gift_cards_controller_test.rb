require "test_helper"

class GiftCardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @buyer = User.create!(
      email: "gift-buyer@example.com",
      password: "password123",
      user_role: :customer,
      stripe_customer_id: "cus_buyer"
    )
    @gift_card = GiftCard.create!(
      purchaser: @buyer,
      amount: 50,
      balance: 50,
      recipient_email: "recipient@example.com",
      status: :pending
    )
    sign_in @buyer, scope: :user
  end

  test "payment success does not activate card when stripe session verification fails" do
    session = checkout_session(amount_total: 100)

    Stripe::Checkout::Session.stub(:retrieve, session) do
      get payment_success_gift_card_path(@gift_card), params: { session_id: "cs_bad" }
    end

    assert @gift_card.reload.pending?
    assert_redirected_to gift_card_path(@gift_card)
  end

  private

  CheckoutSession = Struct.new(:id, :payment_status, :mode, :customer, :amount_total, :metadata, keyword_init: true)

  def checkout_session(amount_total:)
    CheckoutSession.new(
      id: "cs_bad",
      payment_status: "paid",
      mode: "payment",
      customer: "cus_buyer",
      amount_total: amount_total,
      metadata: {
        "type" => "gift_card",
        "gift_card_id" => @gift_card.id.to_s,
        "buyer_id" => @buyer.id.to_s
      }
    )
  end
end

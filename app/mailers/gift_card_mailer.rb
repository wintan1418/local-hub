class GiftCardMailer < ApplicationMailer
  def recipient_notification(gift_card)
    @gift_card = gift_card
    @purchaser = gift_card.purchaser
    @recipient_name = gift_card.recipient_name.presence || "there"
    @code = gift_card.formatted_code
    @amount = gift_card.amount
    @message = gift_card.message
    @redeem_url = Rails.application.routes.url_helpers.gift_cards_url

    mail(
      to: gift_card.recipient_email,
      subject: "🎁 You've received a $#{@amount} gift card from #{@purchaser.display_name}"
    )
  end
end

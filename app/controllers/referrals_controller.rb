class ReferralsController < ApplicationController
  before_action :authenticate_user!

  def show
    current_user.update(referral_code: "#{(current_user.first_name || 'user').parameterize}-#{SecureRandom.hex(3).upcase}") if current_user.referral_code.blank?
    @referral_code = current_user.referral_code
    @referral_url = "#{request.base_url}/users/sign_up?ref=#{@referral_code}"
    @referrals_sent = current_user.referrals_sent.includes(:referee).order(created_at: :desc)
    @credit = current_user.referral_credit || 0
  end
end

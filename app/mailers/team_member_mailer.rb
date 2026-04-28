class TeamMemberMailer < ApplicationMailer
  def invitation(team_member)
    @team_member = team_member
    @provider = team_member.provider
    @business_name = @provider.business_name.presence || @provider.display_name
    @role = team_member.role.titleize
    @invite_token = team_member.invite_token
    @sign_up_url = Rails.application.routes.url_helpers.new_user_registration_url(invite_token: @invite_token)

    mail(
      to: team_member.invite_email,
      subject: "#{@provider.display_name} invited you to join #{@business_name} on Radius"
    )
  end
end

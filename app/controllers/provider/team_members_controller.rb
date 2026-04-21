class Provider::TeamMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_provider!

  def index
    @team_members = current_user.team_members.includes(:member).order(created_at: :desc)
  end

  def new
    @team_member = current_user.team_members.build
  end

  def create
    @team_member = current_user.team_members.build(team_member_params)
    # Link if email exists
    existing = User.find_by(email: @team_member.invite_email)
    @team_member.member = existing if existing
    @team_member.status = existing ? :active : :invited

    if @team_member.save
      # TODO: send invitation email with invite_token
      redirect_to provider_team_members_path, notice: "Team member #{existing ? 'added' : 'invited'}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @team_member = current_user.team_members.find(params[:id])
    @team_member.update(status: :removed)
    redirect_to provider_team_members_path, notice: "Team member removed."
  end

  private

  def team_member_params
    params.require(:team_member).permit(:invite_email, :role)
  end

  def ensure_provider!
    redirect_to root_path, alert: "Access denied." unless current_user&.provider?
  end
end

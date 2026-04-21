class Provider::SitesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_provider!

  def edit
    @user = current_user
    @user.ensure_slug if @user.slug.blank?
    @faqs = @user.provider_faqs
  end

  def update
    @user = current_user
    if @user.update(site_params)
      redirect_to edit_provider_site_path, notice: "Site updated."
    else
      @faqs = @user.provider_faqs
      render :edit, status: :unprocessable_entity
    end
  end

  def publish
    current_user.update(site_published: true)
    redirect_to edit_provider_site_path, notice: "Site published at #{current_user.site_url}"
  end

  def unpublish
    current_user.update(site_published: false)
    redirect_to edit_provider_site_path, notice: "Site unpublished."
  end

  private

  def site_params
    params.require(:user).permit(:slug, :site_theme, :site_brand_color, :site_tagline, :site_about, :site_cover_photo)
  end

  def ensure_provider!
    redirect_to root_path, alert: "Access denied." unless current_user&.provider?
  end
end

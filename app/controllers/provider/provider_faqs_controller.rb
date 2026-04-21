class Provider::ProviderFaqsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_provider!

  def create
    faq = current_user.provider_faqs.build(faq_params)
    faq.save
    redirect_to edit_provider_site_path, notice: "FAQ added."
  end

  def update
    faq = current_user.provider_faqs.find(params[:id])
    faq.update(faq_params)
    redirect_to edit_provider_site_path, notice: "FAQ updated."
  end

  def destroy
    faq = current_user.provider_faqs.find(params[:id])
    faq.destroy
    redirect_to edit_provider_site_path, notice: "FAQ removed."
  end

  private

  def faq_params
    params.require(:provider_faq).permit(:question, :answer, :sort_order)
  end

  def ensure_provider!
    redirect_to root_path, alert: "Access denied." unless current_user&.provider?
  end
end

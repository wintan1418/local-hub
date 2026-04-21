class JobRequestQuotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job_request

  def create
    redirect_to root_path, alert: "Only providers can submit quotes." and return unless current_user.provider?
    @quote = @job_request.quotes.build(quote_params)
    @quote.provider = current_user
    @quote.status = :pending

    if @quote.save
      redirect_to job_request_path(@job_request), notice: "Quote submitted!"
    else
      redirect_to job_request_path(@job_request), alert: @quote.errors.full_messages.to_sentence
    end
  end

  def accept
    @quote = @job_request.quotes.find(params[:id])
    unless @job_request.customer == current_user
      redirect_to root_path, alert: "Access denied." and return
    end

    @quote.accepted!
    @job_request.awarded!
    # Decline other quotes
    @job_request.quotes.where.not(id: @quote.id).update_all(status: JobRequestQuote.statuses[:declined])
    redirect_to job_request_path(@job_request), notice: "Quote accepted. Contact #{@quote.provider.display_name} to proceed."
  end

  private

  def set_job_request
    @job_request = JobRequest.find(params[:job_request_id])
  end

  def quote_params
    params.require(:job_request_quote).permit(:price, :message)
  end
end

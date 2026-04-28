class JobRequestQuotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job_request
  before_action :set_quote, only: [ :edit, :update ]
  before_action :ensure_owner_and_editable, only: [ :edit, :update ]

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

  def edit
  end

  def update
    if @quote.update(quote_params)
      redirect_to job_request_path(@job_request), notice: "Quote updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def accept
    @quote = @job_request.quotes.find(params[:id])
    unless @job_request.customer == current_user
      redirect_to root_path, alert: "Access denied." and return
    end

    @quote.accepted!
    @job_request.awarded!
    @job_request.quotes.where.not(id: @quote.id).update_all(status: JobRequestQuote.statuses[:declined])
    redirect_to job_request_path(@job_request), notice: "Quote accepted. Contact #{@quote.provider.display_name} to proceed."
  end

  private

  def set_job_request
    @job_request = JobRequest.find(params[:job_request_id])
  end

  def set_quote
    @quote = @job_request.quotes.find(params[:id])
  end

  def ensure_owner_and_editable
    unless @quote.provider == current_user
      redirect_to job_request_path(@job_request), alert: "Access denied." and return
    end
    unless @quote.pending?
      redirect_to job_request_path(@job_request), alert: "This quote has already been #{@quote.status} and can no longer be edited."
    end
  end

  def quote_params
    params.require(:job_request_quote).permit(:price, :message)
  end
end

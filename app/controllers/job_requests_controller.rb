class JobRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job_request, only: [:show, :edit, :update, :destroy]

  def index
    if current_user.customer?
      @job_requests = current_user.job_requests.includes(:category, :quotes)
    else
      @job_requests = JobRequest.includes(:category, :customer)
      @job_requests = @job_requests.where(status: params[:status].presence || :open)
    end

    @job_requests = @job_requests.where(category_id: params[:category_id]) if params[:category_id].present?
    @job_requests = @job_requests.order(created_at: :desc).page(params[:page]).per(20)
    @categories = Category.order(:name) if current_user.provider?
  end

  def show
    @quotes = @job_request.quotes.includes(:provider).order(created_at: :desc)
    @my_quote = current_user.provider? ? @quotes.find_by(provider_id: current_user.id) : nil
  end

  def new
    redirect_to root_path, alert: "Only customers can post requests." unless current_user.customer?
    @job_request = JobRequest.new
    @categories = Category.order(:name)
  end

  def create
    redirect_to root_path, alert: "Only customers can post requests." and return unless current_user.customer?
    @job_request = current_user.job_requests.build(job_request_params)
    @job_request.status = :open
    if @job_request.save
      redirect_to job_request_path(@job_request), notice: "Job posted! Providers will send quotes soon."
    else
      @categories = Category.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @job_request.destroy
    redirect_to job_requests_path, notice: "Request removed."
  end

  private

  def set_job_request
    @job_request = JobRequest.find(params[:id])
  end

  def job_request_params
    params.require(:job_request).permit(:category_id, :title, :description, :budget_min, :budget_max, :needed_by, :city, :state, :zip)
  end
end

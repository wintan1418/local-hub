class Provider::QuotesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_provider!

  def index
    @quotes = Quote.where(provider: current_user).includes(:customer, :service, :line_items).order(created_at: :desc)
  end

  def new
    @quote = Quote.new
    @quote.line_items.build
    @services = current_user.services
    @customers = User.customer.order(:first_name)
  end

  def create
    @quote = Quote.new(quote_params)
    @quote.provider = current_user
    @quote.status = :draft

    if @quote.save
      redirect_to provider_quote_path(@quote), notice: "Quote created!"
    else
      @services = current_user.services
      @customers = User.customer.order(:first_name)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @quote = current_user_quotes.find(params[:id])
  end

  def edit
    @quote = current_user_quotes.find(params[:id])
    @services = current_user.services
    @customers = User.customer.order(:first_name)
  end

  def update
    @quote = current_user_quotes.find(params[:id])
    if @quote.update(quote_params)
      redirect_to provider_quote_path(@quote), notice: "Quote updated!"
    else
      @services = current_user.services
      @customers = User.customer.order(:first_name)
      render :edit, status: :unprocessable_entity
    end
  end

  def send_quote
    @quote = current_user_quotes.find(params[:id])
    if @quote.draft?
      @quote.sent!
      UserMailer.quote_sent(@quote).deliver_later rescue nil
      redirect_to provider_quote_path(@quote), notice: "Quote sent to customer!"
    else
      redirect_to provider_quote_path(@quote), alert: "Quote has already been sent."
    end
  end

  def destroy
    @quote = current_user_quotes.find(params[:id])
    @quote.destroy
    redirect_to provider_quotes_path, notice: "Quote deleted."
  end

  private

  def current_user_quotes
    Quote.where(provider: current_user)
  end

  def quote_params
    params.require(:quote).permit(:service_id, :customer_id, :title, :description, :total_price, :valid_until, :notes,
      line_items_attributes: [:id, :description, :quantity, :unit_price, :_destroy])
  end

  def ensure_provider!
    redirect_to root_path, alert: "Access denied." unless current_user&.provider?
  end
end

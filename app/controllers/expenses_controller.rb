class ExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking
  before_action :ensure_provider!

  def create
    @expense = @booking.expenses.build(expense_params)
    if @expense.save
      redirect_to booking_path(@booking), notice: "Expense added."
    else
      redirect_to booking_path(@booking), alert: @expense.errors.full_messages.to_sentence
    end
  end

  def destroy
    @expense = @booking.expenses.find(params[:id])
    @expense.destroy
    redirect_to booking_path(@booking), notice: "Expense removed."
  end

  private

  def set_booking
    @booking = Booking.find(params[:booking_id])
  end

  def ensure_provider!
    unless @booking.service.provider == current_user
      redirect_to root_path, alert: "Access denied."
    end
  end

  def expense_params
    params.require(:expense).permit(:description, :amount, :category)
  end
end

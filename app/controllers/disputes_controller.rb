class DisputesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking

  def new
    @dispute = @booking.build_dispute
    unless @booking.customer == current_user || @booking.service.provider == current_user
      redirect_to root_path, alert: "Access denied." and return
    end
    if @booking.dispute.present?
      redirect_to booking_dispute_path(@booking) and return
    end
  end

  def create
    @dispute = @booking.build_dispute(dispute_params)
    @dispute.raised_by = current_user
    @dispute.status = :open

    if @dispute.save
      # Notify admins
      User.admin.each do |admin|
        Notification.create!(
          user: admin,
          title: "New dispute opened",
          message: "#{current_user.display_name} opened a dispute on booking ##{@booking.id}",
          notification_type: "system_announcement",
          notifiable: @dispute
        )
      end
      redirect_to booking_dispute_path(@booking), notice: "Dispute submitted. Our team will review within 24 hours."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @dispute = @booking.dispute
    redirect_to booking_path(@booking), alert: "No dispute exists." and return unless @dispute
    unless @booking.customer == current_user || @booking.service.provider == current_user || current_user.admin?
      redirect_to root_path, alert: "Access denied."
    end
  end

  private

  def set_booking
    @booking = Booking.find(params[:booking_id])
  end

  def dispute_params
    params.require(:dispute).permit(:reason, :description)
  end
end

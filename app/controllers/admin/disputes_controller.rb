module Admin
  class DisputesController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin!
    before_action :set_dispute, only: [:show, :resolve, :refund, :dismiss]

    def index
      @disputes = Dispute.includes(booking: [:customer, service: :provider], raised_by: []).order(created_at: :desc)
      @disputes = @disputes.where(status: params[:status]) if params[:status].present?
    end

    def show
      @dispute.under_review! if @dispute.open?
    end

    def resolve
      @dispute.update(status: :resolved, resolution: params[:resolution], resolved_at: Time.current)
      redirect_to admin_dispute_path(@dispute), notice: "Dispute marked as resolved."
    end

    def refund
      amount = params[:refund_amount].to_f
      booking = @dispute.booking

      result = StripeService.refund_booking(booking)
      if result[:error]
        redirect_to admin_dispute_path(@dispute), alert: "Stripe refund failed: #{result[:error]}"
        return
      end

      @dispute.update(status: :refunded, refund_amount: amount, resolution: params[:resolution], resolved_at: Time.current)
      booking.update(paid: false)
      Notification.create_for_booking(booking, :updated, "Your refund of $#{amount} has been processed.") if defined?(Notification.create_for_booking)
      redirect_to admin_dispute_path(@dispute), notice: "Refund of $#{amount} processed via Stripe."
    end

    def dismiss
      @dispute.update(status: :dismissed, resolution: params[:resolution], resolved_at: Time.current)
      redirect_to admin_dispute_path(@dispute), notice: "Dispute dismissed."
    end

    private

    def set_dispute
      @dispute = Dispute.find(params[:id])
    end

    def ensure_admin!
      redirect_to root_path, alert: "Access denied." unless current_user&.admin?
    end
  end
end

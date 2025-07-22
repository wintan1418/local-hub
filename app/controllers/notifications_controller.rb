class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications
                               .includes(:notifiable)
                               .order(created_at: :desc)
                               .page(params[:page])
                               .per(20)

    # Mark all as seen when viewing
    current_user.notifications.unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.html
      format.json { render json: @notifications }
    end
  end

  def show
    @notification = current_user.notifications.find(params[:id])
    @notification.update(read_at: Time.current) unless @notification.read?

    # Redirect to the related object if applicable
    if @notification.notifiable.present?
      redirect_to notification_redirect_path(@notification)
    else
      redirect_to notifications_path
    end
  end

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    @notification.update(read_at: Time.current)

    respond_to do |format|
      format.json { render json: { status: 'success' } }
      format.html { redirect_back(fallback_location: notifications_path) }
    end
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.json { render json: { status: 'success' } }
      format.html { redirect_to notifications_path, notice: 'All notifications marked as read.' }
    end
  end

  def destroy
    @notification = current_user.notifications.find(params[:id])
    @notification.destroy

    respond_to do |format|
      format.json { render json: { status: 'success' } }
      format.html { redirect_to notifications_path, notice: 'Notification deleted.' }
    end
  end

  private

  def notification_redirect_path(notification)
    case notification.notifiable_type
    when 'Booking'
      booking = notification.notifiable
      if current_user.provider?
        provider_dashboard_path
      else
        customer_dashboard_path
      end
    when 'ChatMessage'
      message = notification.notifiable
      conversation_path(message.conversation)
    when 'Subscription'
      subscription = notification.notifiable
      if current_user.provider?
        provider_subscriptions_path
      else
        settings_path
      end
    else
      notifications_path
    end
  end
end

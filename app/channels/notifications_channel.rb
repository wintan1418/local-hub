class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    return reject unless current_user
    stream_for current_user
  end

  def unsubscribed
  end
end

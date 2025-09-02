module NotificationsHelper
  def notification_icon(notification)
    case notification.notifiable_type
    when 'Booking'
      '<svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clip-rule="evenodd" />
      </svg>'.html_safe
    when 'ChatMessage'
      '<svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clip-rule="evenodd" />
      </svg>'.html_safe
    when 'Review'
      '<svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
      </svg>'.html_safe
    when 'Subscription'
      '<svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M4 4a2 2 0 00-2 2v4a2 2 0 002 2V6h10a2 2 0 00-2-2H4zm2 6a2 2 0 012-2h8a2 2 0 012 2v4a2 2 0 01-2 2H8a2 2 0 01-2-2v-4zm6 4a2 2 0 100-4 2 2 0 000 4z" clip-rule="evenodd" />
      </svg>'.html_safe
    when 'User' # verification notifications
      '<svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
      </svg>'.html_safe
    else
      '<svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
        <path d="M10 2a6 6 0 00-6 6v3.586l-.707.707A1 1 0 004 14h12a1 1 0 00.707-1.707L16 11.586V8a6 6 0 00-6-6zM10 18a3 3 0 01-3-3h6a3 3 0 01-3 3z" />
      </svg>'.html_safe
    end
  end

  def notification_icon_class(notification)
    case notification.notifiable_type
    when 'Booking'
      'bg-blue-500'
    when 'ChatMessage'
      'bg-green-500'
    when 'Review'
      'bg-yellow-500'
    when 'Subscription'
      'bg-purple-500'
    when 'User'
      'bg-indigo-500'
    else
      'bg-gray-500'
    end
  end

  def notification_title(notification)
    case notification.notifiable_type
    when 'Booking'
      booking = notification.notifiable
      case notification.message
      when /new booking/i
        "New Booking Request"
      when /confirmed/i
        "Booking Confirmed"
      when /completed/i
        "Service Completed"
      when /cancelled/i
        "Booking Cancelled"
      else
        "Booking Update"
      end
    when 'ChatMessage'
      "New Message"
    when 'Review'
      "New Review Received"
    when 'Subscription'
      "Subscription Update"
    when 'User'
      case notification.message
      when /verified/i
        "Verification Update"
      when /approved/i
        "Account Approved"
      else
        "Account Update"
      end
    else
      "Notification"
    end
  end

  def notification_message(notification)
    return notification.message if notification.message.present?
    
    case notification.notifiable_type
    when 'Booking'
      booking = notification.notifiable
      if booking.present?
        "#{booking.service&.title} - #{booking.customer&.display_name}"
      else
        "Booking update available"
      end
    when 'ChatMessage'
      message = notification.notifiable
      if message.present?
        truncate(message.content, length: 100)
      else
        "You have a new message"
      end
    when 'Review'
      review = notification.notifiable
      if review.present?
        "#{review.rating}-star review: #{truncate(review.comment, length: 80)}"
      else
        "You received a new review"
      end
    when 'Subscription'
      "Your subscription status has been updated"
    when 'User'
      "Your account has been updated"
    else
      "You have a new notification"
    end
  end

  def notification_category(notification)
    case notification.notifiable_type
    when 'Booking'
      'Bookings'
    when 'ChatMessage'
      'Messages'
    when 'Review'
      'Reviews'
    when 'Subscription'
      'Billing'
    when 'User'
      'Account'
    else
      'General'
    end
  end

  def notification_unread_count(user)
    return 0 unless user
    user.notifications.unread.count
  end
end
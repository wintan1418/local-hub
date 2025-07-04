class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find(params[:conversation_id])
    
    # Verify user has access to this conversation
    if current_user&.conversations&.include?(conversation)
      stream_for conversation
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
  
  def speak(data)
    conversation = Conversation.find(params[:conversation_id])
    return unless current_user&.conversations&.include?(conversation)
    
    message = conversation.chat_messages.create!(
      sender: current_user,
      content: data['content']
    )
    
    ConversationChannel.broadcast_to(
      conversation,
      {
        message: ApplicationController.render(
          partial: 'conversations/message',
          locals: { message: message, current_user: current_user }
        ),
        sender_id: current_user.id
      }
    )
  end
  
  def start_typing
    conversation = Conversation.find(params[:conversation_id])
    return unless current_user&.conversations&.include?(conversation)
    
    ConversationChannel.broadcast_to(
      conversation,
      {
        typing: true,
        sender_id: current_user.id,
        sender_name: current_user.display_name
      }
    )
  end
  
  def stop_typing
    conversation = Conversation.find(params[:conversation_id])
    return unless current_user&.conversations&.include?(conversation)
    
    ConversationChannel.broadcast_to(
      conversation,
      {
        typing: false,
        sender_id: current_user.id
      }
    )
  end
end

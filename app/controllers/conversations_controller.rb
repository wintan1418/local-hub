class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [ :show, :create_message ]

  def index
    @conversations = current_user.conversations
                                .includes(:customer, :provider, :chat_messages)
                                .recent
                                .page(params[:page])
  end

  def show
    @conversation.mark_as_read_for(current_user)
    @messages = @conversation.chat_messages.includes(:sender).recent
    @other_user = @conversation.other_participant(current_user)

    # Mark messages as read for current user
    @messages.unread_for(current_user).each(&:mark_as_read!)
  end

  def create
    @other_user = User.find(params[:user_id])

    # Determine customer and provider based on roles
    if current_user.customer? && @other_user.provider?
      customer = current_user
      provider = @other_user
    elsif current_user.provider? && @other_user.customer?
      customer = @other_user
      provider = current_user
    else
      redirect_to root_path, alert: "Invalid conversation participants."
      return
    end

    @conversation = Conversation.find_or_create_by(
      customer: customer,
      provider: provider
    )

    respond_to do |format|
      format.html { redirect_to conversation_path(@conversation) }
      format.json { render json: { conversation_id: @conversation.id } }
    end
  end

  def create_message
    @message = @conversation.chat_messages.build(
      sender: current_user,
      content: params[:content]
    )

    if @message.save
      # Broadcast message via ActionCable
      ConversationChannel.broadcast_to(
        @conversation,
        {
          message: render_message(@message),
          sender_id: current_user.id
        }
      )

      head :ok
    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:id])
  end

  def render_message(message)
    ApplicationController.render(
      partial: "conversations/message",
      locals: { message: message, current_user: current_user }
    )
  end
end

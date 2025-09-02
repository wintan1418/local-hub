class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [ :show, :create_message, :edit_message, :delete_message, :pin_message ]
  before_action :set_message, only: [ :edit_message, :delete_message, :pin_message ]

  def index
    @conversations = current_user.conversations
                                .includes(:customer, :provider, :chat_messages)
                                .recent
                                .page(params[:page])
  end

  def show
    @conversation.mark_as_read_for(current_user)
    @messages = @conversation.chat_messages.includes(:sender, :reply_to).visible.recent
    @other_user = @conversation.other_participant(current_user)
    @pinned_messages = @conversation.chat_messages.pinned.includes(:sender).limit(5)

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
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Invalid conversation participants." }
        format.json { render json: { error: "Invalid conversation participants." }, status: :unprocessable_entity }
      end
      return
    end

    @conversation = Conversation.find_or_create_by(
      customer: customer,
      provider: provider
    )

    if @conversation.persisted?
      respond_to do |format|
        format.html { redirect_to conversation_path(@conversation), notice: "Conversation started with #{@other_user.email.split('@').first.titleize}" }
        format.json { render json: { conversation_id: @conversation.id, redirect_url: conversation_path(@conversation) } }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Unable to start conversation. Please try again." }
        format.json { render json: { error: "Unable to create conversation" }, status: :unprocessable_entity }
      end
    end
  end

  def create_message
    @message = @conversation.chat_messages.build(
      sender: current_user,
      content: params[:content] || "",
      reply_to_id: params[:reply_to_id]
    )

    # Handle file attachments if present
    if params[:attachments].present?
      params[:attachments].reject(&:blank?).each do |attachment|
        @message.attachments.attach(attachment)
      end
      
      # Set message type based on attachment
      if @message.attachments.any?
        first_attachment = @message.attachments.first
        content_type = first_attachment.blob.content_type
        if content_type.start_with?('image/')
          @message.message_type = :image
        elsif content_type.start_with?('audio/')
          @message.message_type = :voice
        else
          @message.message_type = :file
        end
      end
    end

    if @message.save
      respond_to do |format|
        format.html { 
          redirect_to conversation_path(@conversation), 
          notice: "Message sent successfully"
        }
        format.json { 
          render json: { 
            status: 'success', 
            message: render_message(@message),
            conversation_id: @conversation.id
          } 
        }
      end
    else
      respond_to do |format|
        format.html { 
          redirect_to conversation_path(@conversation), 
          alert: @message.errors.full_messages.to_sentence 
        }
        format.json { 
          render json: { errors: @message.errors.full_messages }, 
          status: :unprocessable_entity 
        }
      end
    end
  end

  def edit_message
    unless @message.can_modify?(current_user)
      respond_to do |format|
        format.html { redirect_to conversation_path(@conversation), alert: "Cannot edit this message" }
        format.json { render json: { error: "Cannot edit this message" }, status: :forbidden }
      end
      return
    end

    if @message.update(content: params[:content], edited_at: Time.current)
      respond_to do |format|
        format.html { redirect_to conversation_path(@conversation), notice: "Message updated" }
        format.json { render json: { status: 'success', message: render_message(@message) } }
      end
    else
      respond_to do |format|
        format.html { redirect_to conversation_path(@conversation), alert: @message.errors.full_messages.to_sentence }
        format.json { render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def delete_message
    unless @message.can_modify?(current_user)
      respond_to do |format|
        format.html { redirect_to conversation_path(@conversation), alert: "Cannot delete this message" }
        format.json { render json: { error: "Cannot delete this message" }, status: :forbidden }
      end
      return
    end

    @message.soft_delete!
    respond_to do |format|
      format.html { redirect_to conversation_path(@conversation), notice: "Message deleted" }
      format.json { render json: { status: 'success' } }
    end
  end

  def pin_message
    @message.toggle_pin!
    status = @message.pinned? ? "pinned" : "unpinned"
    
    respond_to do |format|
      format.html { redirect_to conversation_path(@conversation), notice: "Message #{status}" }
      format.json { render json: { status: 'success', pinned: @message.pinned? } }
    end
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:id])
  end

  def set_message
    @message = @conversation.chat_messages.find(params[:message_id])
  end

  def render_message(message)
    ApplicationController.render(
      partial: "conversations/message",
      locals: { message: message, current_user: current_user }
    )
  end
end

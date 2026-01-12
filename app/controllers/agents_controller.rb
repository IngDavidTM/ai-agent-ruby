class AgentsController < ApplicationController
  def index
    @conversations = Conversation.order(created_at: :desc)
    if params[:new_chat]
      @conversation = Conversation.new
    else
      @conversation = Conversation.find_by(id: params[:conversation_id]) || @conversations.first || Conversation.new
    end
    @messages = @conversation.messages.order(:created_at)
  end

  def chat
    @conversation = Conversation.find_by(id: chat_params[:conversation_id]) || Conversation.create(title: "New Chat")
    
    # Save user message
    @conversation.messages.create(role: "user", content: chat_params[:message])

    # Get conversation history for context (Limit to last 20 messages for context window optimization)
    history = @conversation.messages.order(:created_at).last(20).map do |msg|
      { role: msg.role, content: msg.content }
    end

    # Call LLM Service
    llm = LlmService.new
    response = llm.chat(history)

    # Save assistant message
    ai_message = @conversation.messages.create(role: response[:role], content: response[:content])

    # Generate title if it's the first message
    if @conversation.messages.count <= 2
      new_title = llm.generate_title(chat_params[:message])
      @conversation.update(title: new_title) if new_title
    end

    respond_to do |format|
      format.html { redirect_to root_path(conversation_id: @conversation.id) }
      format.json { render json: { 
        success: true, 
        conversation_id: @conversation.id, 
        message: ai_message.content,
        html: ApplicationController.helpers.markdown(ai_message.content),
        new_title: new_title,
        time: ai_message.created_at.strftime("%I:%M %p")
      } }
    end
  rescue => e
    Rails.logger.error "Chat Error: #{e.message}"
    respond_to do |format|
      format.html { redirect_to root_path(conversation_id: @conversation.id), alert: "Error: #{e.message}" }
      format.json { render json: { success: false, error: e.message }, status: :unprocessable_entity }
    end
  end

  def destroy
    Conversation.find(params[:id]).destroy
    redirect_to root_path(new_chat: true)
  end

  private

  def chat_params
    params.permit(:message, :conversation_id)
  end
end

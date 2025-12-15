class AgentsController < ApplicationController
  def index
    @conversation = Conversation.last || Conversation.create(title: "New Chat")
    @messages = @conversation.messages.order(:created_at)
  end

  def chat
    @conversation = Conversation.find_by(id: params[:conversation_id]) || Conversation.create(title: "New Chat")
    
    # Save user message
    @conversation.messages.create(role: "user", content: params[:message])

    # Get conversation history for context
    history = @conversation.messages.order(:created_at).map do |msg|
      { role: msg.role, content: msg.content }
    end

    # Call LLM Service
    llm = LlmService.new(adapter: :openai)
    response = llm.chat(history)

    # Save assistant message
    @conversation.messages.create(role: response[:role], content: response[:content])

    redirect_to root_path(conversation_id: @conversation.id)
  end
end

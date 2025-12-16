class LlmService
  def initialize(adapter: LlmAdapters::GeminiAdapter.new)
    @adapter = adapter
  end

  def chat(messages)
    @adapter.chat(messages)
  end
end

class LlmService
  def initialize(adapter: :openai)
    @adapter = adapter_class(adapter).new
  end

  def chat(messages)
    @adapter.chat(messages)
  end

  private

  def adapter_class(adapter_name)
    case adapter_name
    when :openai
      LlmAdapters::OpenAiAdapter
    else
      raise ArgumentError, "Unknown adapter: #{adapter_name}"
    end
  end
end

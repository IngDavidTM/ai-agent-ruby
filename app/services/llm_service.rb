class LlmService
  def initialize(adapter: LlmAdapters::GeminiAdapter.new)
    @adapter = adapter
  end

  def chat(messages)
    @adapter.chat(messages)
  end

  def generate_title(message)
    prompt = "Generate a very short, concise title (max 5 words) for this conversation based on this user request: \"#{message}\". Return ONLY the title, no quotes."
    response = chat([{ role: "user", content: prompt }])
    response[:content].strip.gsub(/^["']|["']$/, '')
  rescue => e
    Rails.logger.error "Title Generation Error: #{e.message}"
    nil
  end
end

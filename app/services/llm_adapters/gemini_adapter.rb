module LlmAdapters
  class GeminiAdapter
    def initialize
      @api_key = ENV.fetch("GEMINI_API_KEY", nil)
    end

    def chat(messages)
      if @api_key.nil?
        return local_response(messages.last[:content], "No Gemini Key. Set GEMINI_API_KEY.")
      end

      begin
        require 'faraday'
        require 'json'

        # Direct API call to ensure we hit v1beta
        # Direct API call to ensure we hit v1beta
        # Force IPv4 resolution to avoid IPv6 timeout issues on this machine
        require 'resolv'
        host = "generativelanguage.googleapis.com"
        # Get the first A record (IPv4)
        ip = Resolv::DNS.new.getresource(host, Resolv::DNS::Resource::IN::A).address.to_s
        
        url = "https://#{ip}/v1beta/models/gemini-2.5-flash:generateContent?key=#{@api_key}"
        
        conn = Faraday.new(url: url) do |f|
          f.headers['Host'] = host # Required for SNI/VirtualHost
          f.ssl[:verify] = false # Required because we are using IP in URL (Certificate Mismatch expected)
        end
        
        # Prepare payload
        last_message = messages.last[:content]
        payload = {
          contents: [{
            parts: [{ text: last_message }]
          }]
        }

        # Prepare payload
        last_message = messages.last[:content]
        payload = {
          contents: [{
            parts: [{ text: last_message }]
          }]
        }

        response = nil
        # Retry up to 3 times for 503 errors
        3.times do |attempt|
          response = conn.post do |req|
            req.headers['Content-Type'] = 'application/json'
            req.body = payload.to_json
          end

          break unless response.status == 503
          
          sleep(2 ** (attempt + 1)) # 2s, 4s, 8s...
        end

        if response.status == 200
          data = JSON.parse(response.body)
          # Extract text from the deep nested structure
          generated_text = data.dig("candidates", 0, "content", "parts", 0, "text")
          
          if generated_text
            { role: "assistant", content: generated_text }
          else
            local_response(messages.last[:content], "Gemini Empty Response")
          end
        elsif response.status == 503
          local_response(messages.last[:content], "Gemini Overloaded (503). Try again in a minute.")
        else
          local_response(messages.last[:content], "Gemini Error #{response.status}: #{response.body}")
        end

      rescue StandardError => e
        local_response(messages.last[:content], "Connection Error: #{e.message}")
      end
    end

    private

    def local_response(user_text, status_info)
      {
        role: "assistant",
        content: "I'm in Gemini Mode but something went wrong: #{status_info} \n\nYou said: '#{user_text}'."
      }
    end
  end
end

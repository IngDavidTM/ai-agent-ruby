require 'dotenv/load'
require 'faraday'
require 'json'

api_key = ENV['GEMINI_API_KEY']
if api_key.nil? || api_key.strip.empty?
  puts "No GEMINI_API_KEY found in environment."
  exit 1
end

url = "https://generativelanguage.googleapis.com/v1beta/models?key=#{api_key}"
response = Faraday.get(url)

if response.status == 200
  models = JSON.parse(response.body)["models"]
  puts "Available Models:"
  models.each do |m|
    puts "- #{m['name']} (Supported methods: #{m['supportedGenerationMethods']})"
  end
else
  puts "Error listing models: #{response.status} - #{response.body}"
end

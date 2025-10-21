require 'sinatra'
require 'sinatra/cors'
require 'json'
require 'base64'
require './lib/check_writer'

# Configure CORS
set :allow_origin, "http://localhost:3000"
set :allow_methods, "GET,HEAD,POST"
set :allow_headers, "content-type,if-modified-since"
set :expose_headers, "location,link"

# Enable CORS
register Sinatra::Cors

# Serve static files from the frontend build
set :public_folder, 'frontend/build'

# Health check endpoint
get '/api/health' do
  content_type :json
  { status: 'ok', message: 'Check Writer API is running' }.to_json
end

# Generate check PDF
post '/api/generate-check' do
  content_type :json

  begin
    # Parse JSON request body
    request.body.rewind
    data = JSON.parse(request.body.read, symbolize_names: true)

    # Build check attributes
    check_attributes = {
      number: data[:number],
      date: data[:date] ? Date.parse(data[:date]) : Date.today,
      payee_name: data[:payee_name],
      payee_address: parse_address(data[:payee_address]),
      payor_name: data[:payor_name],
      payor_address: parse_address(data[:payor_address]),
      bank_name: data[:bank_name],
      bank_address: parse_address(data[:bank_address]),
      bank_fraction: data[:bank_fraction],
      routing_number: data[:routing_number],
      account_number: data[:account_number],
      amount: data[:amount],
      memo: data[:memo]
    }

    # Remove nil values
    check_attributes.compact!

    # Generate the check
    check = CheckWriter::Check.new(check_attributes)
    pdf_data = check.to_pdf

    # Return PDF as base64 for easy frontend handling
    {
      success: true,
      pdf: Base64.strict_encode64(pdf_data),
      message: 'Check generated successfully'
    }.to_json

  rescue => e
    status 500
    {
      success: false,
      error: e.message,
      backtrace: e.backtrace.first(5)
    }.to_json
  end
end

# Helper to parse address string or array
def parse_address(address)
  return [] if address.nil? || address.empty?

  if address.is_a?(String)
    # Split by newlines or commas
    address.split(/[\n,]/).map(&:strip).reject(&:empty?)
  elsif address.is_a?(Array)
    address
  else
    [address.to_s]
  end
end

# Serve the React app for all other routes (for client-side routing)
get '/*' do
  if File.exist?(File.join(settings.public_folder, 'index.html'))
    send_file File.join(settings.public_folder, 'index.html')
  else
    "Frontend not built yet. Run 'npm run build' in the frontend directory."
  end
end

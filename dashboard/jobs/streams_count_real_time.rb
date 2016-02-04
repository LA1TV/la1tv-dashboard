require 'google/api_client'
require 'date'

# Update these to match your own apps credentials
service_account_email = 'la1tv-918@eternal-argon-120209.iam.gserviceaccount.com' # Email of service account
key_file = './keyfile.p12' # File containing your private key
key_secret = 'notasecret' # Password to unlock private key
profileID = '91620086' # Analytics profile ID.
max_amount = 300

# Get the Google API client
client = Google::APIClient.new(
  :application_name => 'LA1TV Dashboard',
  :application_version => '0.01'
)

visitors = []

# Load your credentials for the service account
key = Google::APIClient::KeyUtils.load_from_pkcs12(key_file, key_secret)
client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience => 'https://accounts.google.com/o/oauth2/token',
  :scope => 'https://www.googleapis.com/auth/analytics.readonly',
  :issuer => service_account_email,
  :signing_key => key)

# Start the scheduler
SCHEDULER.every '5s', :first_in => 0 do

  # Request a token for our service account
  client.authorization.fetch_access_token!

  # Get the analytics API
  analytics = client.discovered_api('analytics','v3')

  # Execute the query
  visitCount = client.execute(:api_method => analytics.data.realtime.get, :parameters => {
    'ids' => "ga:" + profileID,
    'metrics' => "rt:activeUsers",
    "dimensions" => "rt:eventAction"
  })

  visitCount.data.rows.each do |row|
      if row[0] == 'playing'
        visitors << { x: Time.now.to_i, y: row[1].to_i }
        break
      end
  end
  
  if visitors.size > max_amount
    visitors.shift
  end

  # Update the dashboard
  send_event('streams_count_real_time', points: visitors)
end

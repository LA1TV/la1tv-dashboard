require 'rest-client'

config = JSON.parse(File.read('./priv-config.json'))
apiKey = config['la1']['apiKey']

SCHEDULER.every '15s', :first_in => 0 do |job|
  
  url = "https://www.la1tv.co.uk/api/v1/mediaItems/stats/watchingNow?pretty=0"
  puts "Making la1 watching now api request..."
  response = RestClient.get(url, {:"X-Api-Key" => apiKey})
  puts "La1 watching now api request completed."
   
  total = JSON.parse(response.body)['data']['total']

  send_event('la1_watching_now', { current: total } )
end
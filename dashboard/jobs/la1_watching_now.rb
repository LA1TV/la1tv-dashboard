require 'rest-client'
require 'date'

config = JSON.parse(File.read('./priv-config.json'))
apiKey = config['la1']['apiKey']

maxAmount = 500
watchers = []

SCHEDULER.every '5s', :first_in => 0 do |job|
  
  url = "https://www.la1tv.co.uk/api/v1/mediaItems/stats/watchingNow?pretty=0"
  puts "Making la1 watching now api request..."
  response = RestClient.get(url, {:"X-Api-Key" => apiKey})
  puts "La1 watching now api request completed."
   
  currentWatchers = JSON.parse(response.body)['data']['total']
    
  watchers << { x: Time.now.to_i, y: currentWatchers }

  if watchers.size > maxAmount
    watchers.shift
  end
  
  send_event('la1_watching_now', points: watchers )
end
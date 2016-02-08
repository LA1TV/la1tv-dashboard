require 'rest-client'

config = JSON.parse(File.read('./priv-config.json'))
apiKey = config['la1']['apiKey']

SCHEDULER.every '20s', :first_in => 0 do |job|
  streams = []

  url = "https://www.la1tv.co.uk/api/v1/mediaItems/?pretty=0&streamIncludeSetting=HAS_LIVE_STREAM"
  puts "Making la1 streams api request..."
  response = RestClient.get(url, {:"X-Api-Key" => apiKey})
  puts "La1 streams api request completed."
   
  mediaItems = JSON.parse(response.body)['data']['mediaItems']

  streams += mediaItems.map { |mediaItem| 
    { 
      label: mediaItem['name']
    }
  }
  send_event('la1_streams', { items: streams } )
end
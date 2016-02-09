require 'rest-client'

config = JSON.parse(File.read('./priv-config.json'))
apiKey = config['la1']['apiKey']

SCHEDULER.every '45s', :first_in => 0 do |job|
  streams = []

  url = "https://www.la1tv.co.uk/api/v1/mediaItems/?pretty=0&vodIncludeSetting=VOD_PROCESSING"
  puts "Making la1 processing api request..."
  response = RestClient.get(url, {:"X-Api-Key" => apiKey})
  puts "La1 processing api request completed."
   
  mediaItems = JSON.parse(response.body)['data']['mediaItems']

  streams += mediaItems.map { |mediaItem| 
    processingMsg = mediaItem['vod']['processing']['message']
    percentage = mediaItem['vod']['processing']['percentage']
    if !percentage.nil?
      processingMsg << " (#{percentage}%)"
    end

    { 
      label: mediaItem['name'],
      value: processingMsg
    }
  }
  send_event('la1_processing', { items: streams } )
end
require 'uptimerobot'

config = JSON.parse(File.read('./priv-config.json'))
apiKeys = config['uptimeRobot']['apiKeys']

SCHEDULER.every '1m', :first_in => 0 do |job|
  monitors = []

  apiKeys.each { |apiKey|
    client = UptimeRobot::Client.new(apiKey: apiKey)

    rawMonitors = client.getMonitors['monitors']['monitor']

    monitors += rawMonitors.map { |monitor| 
      { 
        friendlyname: monitor['friendlyname'], 
        status: 'S' << monitor['status']
      }
    }
  }
  send_event('uptimerobot', { monitors: monitors } )
end
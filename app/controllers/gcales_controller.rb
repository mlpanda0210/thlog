class GcalesController < ActionController::Base



 def index

end

def init_client
    Schedule.delete_all
    client = Google::APIClient.new
    client.authorization.access_token = current_user.token
    client.authorization.client_id = ENV['GOOGLE_CLIENT_ID']
    client.authorization.client_secret = ENV['GOOGLE_CLIENT_SECRET']
    client.authorization.refresh_token = current_user.refresh_token
    service = client.discovered_api('calendar', 'v3')

    responses = client.execute(
    :api_method => service.events.list,
    :parameters => {'calendarId' => 'primary',
      'maxResults' => 2500},
    :headers => {'Content-Type' => 'application/json'})

    events = []

    responses.data.items.each do |item|
      events << item
    end

    events.each do |event|
      if event.summary.nil? || event["start"]["dateTime"].nil? then
        next
      end
      if event["start"]["dateTime"].to_s.include?("2016-04")
        @schedule = Schedule.new
        @schedule.summary = event["summary"]
        @schedule.description = event["description"]
        @schedule.starttime = event["start"]["dateTime"]
        @schedule.endtime = event["end"]["dateTime"]
        @schedule.save
      end
    end
  end
end

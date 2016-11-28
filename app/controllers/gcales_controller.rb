class GcalesController < ActionController::Base


 def new
   @search =Form::Search.new
   binding.pry

 end

 def index

end

def init_client

    year = params[search_month(1i)]
    month = params[search_month(2i)]

    Tag.delete_all
    client = Google::APIClient.new
    client.authorization.access_token = current_user.token
    client.authorization.client_id = ENV['GOOGLE_CLIENT_ID']
    client.authorization.client_secret = ENV['GOOGLE_CLIENT_SECRET']
    client.authorization.refresh_token = current_user.refresh_token
    service = client.discovered_api('calendar', 'v3')

    @responses = client.execute(
    :api_method => service.events.list,
    :parameters => {'calendarId' => 'primary',
      'maxResults' => 2500},
    :headers => {'Content-Type' => 'application/json'})

    events = []

    @responses.data.items.each do |item|
      events << item
    end

    events.each do |event|
      if event.summary.nil? || event["start"]["dateTime"].nil? then
        next
      end
      if event["start"]["dateTime"].to_s.include?("2016-11")  then
        @tag = Tag.new
        @tag.user_id=current_user.id
        @tag.summary = event["summary"]
        @tag.description = event["description"]
        @tag.starttime = event["start"]["dateTime"]
        @tag.endtime = event["end"]["dateTime"]
        @tag.save
      end
    end
  end

def calc_each_project

    @sum_time = Tag.calc_work_time("[projectA]")
    binding.pry
  end

  private
    def searches_params
      params.require(:form_search).permit(Form::Search::REGISTRABLE_ATTRIBUTES)
    end
end

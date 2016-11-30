class GcalesController < ActionController::Base


 def new
   @search =Form::Search.new
   @tag = Tag.new
 end

 def index

end

def init_client
    Schedule.delete_all
    Tag.delete_all
    @tag = Tag.new(tags_params)
    @tag.save
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

      year = params["form_search"]["search_month(1i)"]
      month = params["form_search"]["search_month(2i)"]
      year_month = year+"-"+month
      if event["start"]["dateTime"].to_s.include?(year_month)  then
        @schedule_year_month = Schedule.new
        @schedule_year_month.user_id=current_user.id
        @schedule_year_month.summary = event["summary"]
        @schedule_year_month.description = event["description"]
        @schedule_year_month.starttime = event["start"]["dateTime"]
        @schedule_year_month.endtime = event["end"]["dateTime"]
        @schedule_year_month.save
      end
    end
    Schedule.tag_work_time
    @schedules_tag = Schedule.all
    @sum_time_tag = Schedule.sum_work_time
  end



def calc_each_project
  end

  private
    def searches_params
      params.require(:form_search).permit(Form::Search::REGISTRABLE_ATTRIBUTES)
    end
    def tags_params
      params.require(:tag).permit(:id,:tag)
    end
end

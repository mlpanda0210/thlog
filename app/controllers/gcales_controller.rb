class GcalesController < ApplicationController
  before_action :authenticate_user!


 def new
   @search =Form::Search.new
 end

 def index

end

def init_client
    Schedule.delete_all
    Tag.delete_all
    Day.delete_all
    Tag.add_tags(params[:projects], current_user.id)
    @year = params["form_search"]["search_month(1i)"]
    @month = params["form_search"]["search_month(2i)"]
    year_month = @year+"-"+@month

    Day.make_days_database(@year,@month,current_user.id)


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

      if event["start"]["dateTime"].to_s.include?(year_month)  then
        @schedule_year_month = Schedule.new
        @schedule_year_month.user_id=current_user.id
        @schedule_year_month.summary = event["summary"]
        @schedule_year_month.description = event["description"]
        @schedule_year_month.starttime = event["start"]["dateTime"]
        @schedule_year_month.endtime = event["end"]["dateTime"]
        @schedule_year_month.year = @year
        @schedule_year_month.month = @month
        @schedule_year_month.day_month = event["start"]["dateTime"].day.to_i
        @schedule_year_month.save
      end
    end

    Schedule.add_tag_id
    Schedule.add_day_id
    @tags = Tag.all
    @schedules = Schedule.all
    @sum_time_tag = Schedule.sum_work_time

  end



def calc_each_project
  end

  private
    def searches_params
      params.require(:form_search).permit(Form::Search::REGISTRABLE_ATTRIBUTES)
    end
    def tags_params
      params.require(:tag).permit(:tag)
    end

end

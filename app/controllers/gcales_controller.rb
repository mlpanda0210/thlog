class GcalesController < ApplicationController
  before_action :authenticate_user!


 def new
   @search =Form::Search.new
   @tags = Tag.all
 end


 def index
   Schedule.delete_all
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
       @schedule_year_month = Schedule.new
       @schedule_year_month.user_id=current_user.id
       @schedule_year_month.summary = event["summary"]
       @schedule_year_month.description = event["description"]
       @schedule_year_month.starttime = event["start"]["dateTime"]
       @schedule_year_month.endtime = event["end"]["dateTime"]
       @schedule_year_month.year = event["start"]["dateTime"].year.to_i
       @schedule_year_month.month = event["start"]["dateTime"].month.to_i
       @schedule_year_month.day_month = event["start"]["dateTime"].day.to_i
       @schedule_year_month.spendtime = (@schedule_year_month.endtime-@schedule_year_month.starttime)/3600
       @schedule_year_month.save
   end
   @tags = Tag.all
end

def init_client
    Day.delete_all
    @year = params["form_search"]["search_month(1i)"]
    @month = params["form_search"]["search_month(2i)"]
    year_month = @year+"-"+@month
    Day.make_days_database(@year,@month,current_user.id)
    @schedules =  Schedule.where(year: @year,month: @month)
    @schedules.add_tag_id
    @schedules.add_day_id
    @tags = Tag.all
    @sum_time_tag = @schedules.sum_work_time

    total_array=[]

    @sum_time_tag.each do |s|
      array=[s.name,s.sum_time]
      total_array.push(array)
    end

    @graph = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: '円グラフ')
      f.series(name: 'プロジェクト別工数', data: total_array, type: 'pie')
    end
  end


 def day
  @tags = Tag.all
  @days = Day.all
  @schedules = Schedule.all
 end

 def new_tag
   @tag = Tag.new
 end

 def create_tag
   Tag.add_tags(params[:projects], current_user.id)
   redirect_to gcales_path
 end

 def destroy_tag
     @tag = Tag.find(params[:id])
     @tag.destroy
     redirect_to gcales_path
 end


 def edit_tag
  @tags = Tag.all
 end

 def update_tag
 end


  private
    def searches_params
      params.require(:form_search).permit(Form::Search::REGISTRABLE_ATTRIBUTES)
    end
    def tags_params
      params.require(:tag).permit(:name)
    end

end

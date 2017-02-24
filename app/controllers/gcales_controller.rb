class GcalesController < ApplicationController
  before_action :authenticate_user!

  def new
    @search =Form::Search.new
    @tags = Tag.all
  end

  def update_schedule
    Schedule.where(user_id: current_user.id).delete_all
    client = Google::APIClient.new
    client.authorization.access_token = current_user.token
    client.authorization.client_id = ENV['GOOGLE_CLIENT_ID']
    client.authorization.client_secret = ENV['GOOGLE_CLIENT_SECRET']
    client.authorization.refresh_token = current_user.refresh_token
    service = client.discovered_api('calendar', 'v3')
    @responses = client.execute(
    :api_method => service.events.list,
    :parameters => {'calendarId' => 'primary',
      'timeMin'=> (Time.now - 6.months).iso8601,
      'timeMax'=> (Time.now + 1.months).iso8601,
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
        if event.summary.include?("プライベート")||event.summary.include?("業務外")||event.summary.include?("private")then
          next
        end
        if event["attendees"].present?  then
          if event["attendees"].select{|a,b,c,d|a["email"] == current_user.email}[0]["responseStatus"] != "accepted"  then
            next
          end
        end
        @schedule_year_month = Schedule.new
        @schedule_year_month.event_id = event["id"]
        @schedule_year_month.user_id = current_user.id
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
      redirect_to gcales_path, notice: "スケジュールを登録しました!"
    end

    def index
      @tags = Tag.where.not(name:["other"]).where(user_id: current_user.id).order(created_at: :desc)
    end

    def index_month_project
      Day.delete_all
      @graphs=[]
      @user = current_user
      for num in 0..5 do
        @year = (Date.today << num).year
        @month = (Date.today << num).month
        @schedules =  Schedule.where(year: @year,month: @month).where(user_id: current_user.id)
        @schedules.add_tag_id(current_user.id)
        @schedules.add_day_id(current_user.id)
        @tags = Tag.all.where(user_id: current_user.id)
        @sum_time_tag = @schedules.month_sum_work_time(current_user.id)
        total_array=[]
        @sum_time_tag.each do |s|
          array=[s.description,s.sum_time]
          total_array.push(array)
        end
        graph = LazyHighCharts::HighChart.new('graph') do |f|
          f.title(text: @year.to_s+'年'+@month.to_s+'月')
          f.series(name: 'プロジェクト別工数', data: total_array, type: 'pie', :dataLabels => { :enabled => false })
          f.plot_options ({:pie=>{showInLegend: true}})
          f.options[:subtitle] = @year.to_s+'年'+@month.to_s+"月for"+@user.id.to_s
          f.options[:user] = @user
        end
        @graphs.push(graph)
      end
    end

    def show_month_project
      year_month = params[:graph]
      year_month = year_month.delete("月")
      year_month = year_month.split("年")
      @year = year_month[0]
      @month = year_month[1]
      @schedules = Schedule.where(year: @year, month: @month).where(user_id: current_user.id).order(starttime: :asc)
      @tags = Tag.all.where(user_id: current_user.id).order(created_at: :desc)
      @user = current_user
    end

    def index_month_working_hours
      @user = current_user
      @graphs = []

      total_hash={}
      total_array=[]
      total_sum_time_tag = []
      total_sum_time_tag2 = []
      total_array_year_month = []
      for num in 0..4 do
        @year = (Date.today << num).year
        @month = (Date.today << num).month
        year_month = @year.to_s+'年'+@month.to_s+"月"
        total_array_year_month.push(year_month)
        @schedules =  Schedule.where(year: @year,month: @month).where(user_id: current_user.id)
        @schedules.add_tag_id(current_user.id)
        @schedules.add_day_id(current_user.id)
        @tags = Tag.all.where(user_id: current_user.id)
        @sum_time_tag = @schedules.month_sum_work_time(current_user.id)
        total_sum_time_tag = total_sum_time_tag + @sum_time_tag
        total_sum_time_tag2 = total_sum_time_tag.group_by{ |a| a.id}
      end

      total_sum_time_tag2.each do |t|
        temp_hash={}
        temp_array=[]
        temp_hash[:name] = t[1][0].description
        t[1].each_with_index do |g,i|
          temp_array.push(t[1][i].sum_time)
        end
        temp_hash[:data]=temp_array
        total_array.push(temp_hash)
      end

      graph = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(text: current_user.name.to_s+'の工数')
        total_array.each do |t|
          f.series(:name=> t[:name], :data=> t[:data])
        end
        f.options[:subtitle] = @year.to_s+'年'+@month.to_s+"月for"+current_user.id.to_s
        f.xAxis(:categories => total_array_year_month)
        f.yAxis(:title =>{:text=>"hours"})
        f.options[:chart][:defaultSeriesType] = "column"
        f.plot_options({:column=>{:stacking=>"normal"}})
        f.options[:user] = current_user
      end
      @graphs.push(graph)
    end

    def day
      @tags = Tag.all.where(user_id: current_user.id)
      @days = Day.all.where(user_id: current_user.id)
      @schedules = Schedule.all.where(user_id: current_user.id)
    end

    def new_tag
      @tag = Tag.new
    end

    def create_tag
      Tag.add_tags(params[:projects_name], params[:projects_description], current_user.id)
      redirect_to gcales_path, notice: "タグを登録しました"

    end

    def destroy_tag
      @tag = Tag.find(params[:id])
      @tag.destroy
      redirect_to gcales_path, notice: "タグを削除しました"
    end

    def edit_tag
      @tag = Tag.find(params[:id])
    end

    def update_tag
      @tag = Tag.find(params[:id])
      @tag.update(tags_params)
      redirect_to gcales_path,  notice: "タグを編集しました"
    end

    def download_manual
      file_name="Manual.pdf"
      filepath = Rails.root.join('public',file_name)
      stat = File::stat(filepath)
      send_file(filepath, :filename => file_name, :length => stat.size)
    end

    def edit_schedule_contents
      @schedule = Schedule.find(params[:id])
    end

    def update_schedule_contents
      schedule = params[:schedule]
      Schedule.update_events(current_user,schedule)
      schedule_db = Schedule.find_by(event_id: schedule[:event_id])
      @year = schedule_db.year.to_s
      @month =  schedule_db.month.to_s
      @schedules =  Schedule.where(year: @year,month: @month).where(user_id: current_user.id)
      @schedules.add_tag_id(current_user.id)
      graph = @year + '年' + @month + '月'
      redirect_to gcales_show_month_project_path(graph: graph)
    end

    private
    def searches_params
      params.require(:form_search).permit(Form::Search::REGISTRABLE_ATTRIBUTES)
    end

    def tags_params
      params.require(:tag).permit(:name,:description)
    end
  end

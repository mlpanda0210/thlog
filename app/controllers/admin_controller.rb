class AdminController < ApplicationController
  before_action :authenticate_admin!

  def admin_index_users
    @users = User.all
    @tags = Tag.where.not(name: "other")
  end

  def admin_show_user
    @pie_graphs=[]
    @column_graphs=[]
    @user = User.find(params[:id])
    for num in 1..2 do
      @year = (Date.today << num).year
      @month = (Date.today << num).month
      @schedules =  Schedule.where(year: @year,month: @month).where(user_id: @user.id)
      @schedules.add_tag_id(@user.id)
      @schedules.add_day_id(@user.id)
      @tags = Tag.all.where(user_id: @user.id)
      @sum_time_tag = @schedules.month_sum_work_time(@user.id)
      total_array=[]
      @sum_time_tag.each do |s|
        array=[s.description,s.sum_time]
        total_array.push(array)
      end
      pie_graph = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(text: @year.to_s+'年'+@month.to_s+'月')
        f.series(name: 'プロジェクト別工数', data: total_array, type: 'pie', :dataLabels => { :enabled => false })
        f.plot_options ({:pie=>{showInLegend: true}})
        f.options[:user] = @user
      end
      @pie_graphs.push(pie_graph)
    end
    total_hash={}
    total_array=[]
    total_sum_time_tag = []
    total_sum_time_tag2 = []
    total_array_year_month = []
    for num in 1..5 do
      @year = (Date.today << num).year
      @month = (Date.today << num).month
      year_month = @year.to_s+'年'+@month.to_s+"月"
      total_array_year_month.push(year_month)
      @schedules =  Schedule.where(year: @year,month: @month).where(user_id: @user.id)
      @schedules.add_tag_id(@user.id)
      @schedules.add_day_id(@user.id)
      @tags = Tag.all.where(user_id: @user.id)
      @sum_time_tag = @schedules.month_sum_work_time(@user.id)
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
    column_graph = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: @user.name.to_s+'の工数')
      total_array.each do |t|
        f.series(:name=> t[:name], :data=> t[:data])
      end
      f.options[:subtitle] = @year.to_s+'年'+@month.to_s+"月for"+@user.id.to_s
      f.xAxis(:categories => total_array_year_month)
      f.yAxis(:max => 200,:title =>{:text=>"hours"})
      f.options[:chart][:defaultSeriesType] = "column"
      f.plot_options({:column=>{:stacking=>"normal"}})
      f.options[:user] = @user
    end
    @column_graphs.push(column_graph)
  end

  def admin_show_month_project
    @user = User.find(params[:id])
    year_month = params[:graph]
    year_month = year_month.delete("月")
    year_month = year_month.split("年")
    @year = year_month[0]
    @month = year_month[1]
    @schedules = Schedule.where(year: @year, month: @month).where(user_id: @user.id).order(starttime: :asc)
    @tags = Tag.all.where(user_id: @user.id).order(created_at: :desc)

  end

  def admin_search_user
    @users = User.all
    @tags = Tag.all.where.not(name: "other")
  end

  def admin_result_search_user_by_project
    @year = params[:input]["yearmonth(1i)"]
    @month = params[:input]["yearmonth(2i)"]
    @name = params[:input][:name]
    @time = params[:input][:time]
    @sort_users = User.sort_user_by_project(@year,@month,@name,@time)
  end

  def admin_result_search_user_by_working_time
    @year = params[:input]["yearmonth(1i)"]
    @month = params[:input]["yearmonth(2i)"]
    @time = params[:input][:time]
    @sort_users = User.sort_user_by_working_time(@year,@month,@time)
  end

  def admin_sendmail_for_users_by_project
    @users = params[:users]
    @users.each do |user|
      NoticeMailer.sendmail_for_users_by_project(user).deliver
    end
  end

  def admin_sendmail_for_users_by_working_time
    @users = params[:users]
    @users.each do |user|
      NoticeMailer.sendmail_for_users_by_working_time(user).deliver
    end
  end

  def admin_comparison_working_time
    @users = User.all
    @graphs = []
    @users.each do |user|
      total_hash={}
      total_array=[]
      total_sum_time_tag = []
      total_sum_time_tag2 = []
      total_array_year_month = []
      for num in 1..5 do
        @year = (Date.today << num).year
        @month = (Date.today << num).month
        year_month = @year.to_s+'年'+@month.to_s+"月"
        total_array_year_month.push(year_month)
        @schedules =  Schedule.where(year: @year,month: @month).where(user_id: user.id)
        @schedules.add_tag_id(user.id)
        @schedules.add_day_id(user.id)
        @tags = Tag.all.where(user_id: user.id)
        @sum_time_tag = @schedules.month_sum_work_time(user.id)
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
          f.title(text: user.name.to_s+'の工数')
          total_array.each do |t|
            f.series(:name=> t[:name], :data=> t[:data])
          end
          f.options[:subtitle] = @year.to_s+'年'+@month.to_s+"月for"+user.id.to_s
          f.xAxis(:categories => total_array_year_month)
          f.yAxis(:max => 200,:title =>{:text=>"hours"})
          f.options[:chart][:defaultSeriesType] = "column"
          f.plot_options({:column=>{:stacking=>"normal"}})
          f.options[:user] = user
        end
        @graphs.push(graph)
      end
    end

   def admin_comparison_project
     @users = User.all
     @graphs = []
     @users.each do |user|
       for num in 1..2 do
         @year = (Date.today << num).year
         @month = (Date.today << num).month
         @schedules =  Schedule.where(year: @year,month: @month).where(user_id: user.id)
         @schedules.add_tag_id(user.id)
         @schedules.add_day_id(user.id)
         @tags = Tag.all.where(user_id: user.id)
         @sum_time_tag = @schedules.month_sum_work_time(user.id)
         total_array=[]
         @sum_time_tag.each do |s|
           array=[s.description,s.sum_time]
           total_array.push(array)
         end

         graph = LazyHighCharts::HighChart.new('graph') do |f|
           f.title(text: @year.to_s+'年'+@month.to_s+"月")
           f.series(name: 'プロジェクト別工数', data: total_array, type: 'pie', :dataLabels => { :enabled => false })
           f.plot_options ({:pie=>{showInLegend: true}})
           f.options[:subtitle] = @year.to_s+'年'+@month.to_s+"月for"+user.id.to_s
           f.options[:user] = user
         end
            @graphs.push(graph)
       end
     end
   end


    private
      def searches_params
        params.require(:form_search).permit(Form::Search::REGISTRABLE_ATTRIBUTES)
      end
      def tags_params
        params.require(:tag).permit(:name)
      end

end

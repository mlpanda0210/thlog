class AdminController < ApplicationController
  before_action :authenticate_admin!

  def admin_comparison_working_time
    @users = User.all
    @graphs = []

    @users.each do |user|
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
        @schedules =  Schedule.where(year: @year,month: @month).where(user_id: user.id)
        @schedules.add_tag_id(user.id)
        @schedules.add_day_id(user.id)
        @tags = Tag.all.where(user_id: user.id)
        @sum_time_tag = @schedules.sum_work_time(user.id)
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
       for num in 0..1 do
         @year = (Date.today << num).year
         @month = (Date.today << num).month
         @schedules =  Schedule.where(year: @year,month: @month).where(user_id: user.id)
         @schedules.add_tag_id(user.id)
         @schedules.add_day_id(user.id)
         @tags = Tag.all.where(user_id: user.id)
         @sum_time_tag = @schedules.sum_work_time(user.id)

         total_array=[]
         @sum_time_tag.each do |s|
           array=[s.description,s.sum_time]
           total_array.push(array)
         end

         graph = LazyHighCharts::HighChart.new('graph') do |f|

           f.title(text: @year.to_s+'年'+@month.to_s+"月")
           f.series(name: 'プロジェクト別工数', data: total_array, type: 'pie')
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

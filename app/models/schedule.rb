class Schedule < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag
  belongs_to :day

  def self.add_tag_id
    tags = Tag.all
    tags.each do |tag|
     schedules = Schedule.where("summary like '%"+tag.name+"%'")
     schedules.update_all(tag_id: tag.id)
    end
  end



   def self.sum_work_time
     tags = Tag.all
     tags.each do |tag|
      sum = 0
      schedules = Schedule.where("summary like '%"+tag.name+"%'")
       schedules.each do |schedule|
        work_hours = (schedule.endtime-schedule.starttime)/3600
        sum += work_hours.to_i
      end
     tag.sum_time = sum
     end
   end

   def self.add_day_id
     schedules = Schedule.all
     days = Day.all
     days.each do |day|
       schedules = Schedule.where(year: day.year, month: day.month, day_month: day.day_month)
       schedules.update_all(day_id: day.id)
     end

   end


end

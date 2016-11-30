class Schedule < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag

  def self.tag_work_time
    tags = Tag.all
    tags.each do |tag|
     schedules = Schedule.where("summary like '%"+tag.tag+"%'")
     schedules.update_all(tag_id: tag.id)
    end
  end



   def self.sum_work_time
     tags = Tag.all
     tags.each do |tag|
      sum = 0
      schedules = Schedule.where("summary like '%"+tag.tag+"%'")
       schedules.each do |schedule|
        work_hours = (schedule.endtime-schedule.starttime)/3600
        sum += work_hours.to_i
      end
     tag.sum_time = sum
     end
   end
end

class Schedule < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag
  belongs_to :day

  def self.add_tag_id(user_id)
    tags = Tag.where.not(name:["other"]).where(user_id: user_id)
    tags.each do |tag|
     schedules = self.where("summary ilike '%"+tag.name+"%'")
     schedules.update_all(tag_id: tag.id)
   end
   schedules = self.all.where(user_id: user_id)
   schedules.each do |s|
     if s.tag_id == nil
       s.tag_id = Tag.where(user_id: user_id).find_by(name:"other").id
       s.save
     end
   end
 end

   def self.sum_work_time(user_id)
     tags = Tag.all.where(user_id: user_id)
     tags.each do |tag|
      sum = 0
      schedules = Schedule.where(tag_id: tag.id).where(user_id: user_id)
       schedules.each do |schedule|
        work_hours = (schedule.endtime-schedule.starttime)/3600
        sum += work_hours.to_i
      end
     tag.sum_time = sum
     end
   end

   def self.add_day_id(user_id)
     schedules = Schedule.all.where(user_id: user_id)
     days = Day.all
     days.each do |day|
       schedules = Schedule.where(year: day.year, month: day.month, day_month: day.day_month).where(user_id: user_id)
       schedules.update_all(day_id: day.id)
     end

   end


end

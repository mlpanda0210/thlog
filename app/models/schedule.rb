class Schedule < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag
  belongs_to :day

  def self.add_tag_id(user_id)
    self.where(user_id: user_id).update_all(tag_id: nil)
    tags = Tag.where.not(name:["other"]).where(user_id: user_id)
    tags.each do |tag|
      tag_array = []
      tag_array = tag.name.split
      schedules = self.ransack(summary_cont_any: tag_array).result
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

   def self.month_sum_work_time(user_id)
     tags = Tag.all.where(user_id: user_id).order(created_at: :desc)
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

   def self.copy_user_schedules
      AdminSchedule.delete_all
     self.all.find_each do |s|
       AdminSchedule.create(
       user_id: s.user_id,
       day_id: s.day_id,
       summary: s.summary,
       description: s.description,
       starttime: s.starttime,
       endtime: s.endtime,
       spendtime: s.spendtime,
       year: s.year,
       month: s.month,
       day_month: s.day_month
       )
     end
   end
end

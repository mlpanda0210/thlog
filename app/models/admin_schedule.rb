class AdminSchedule < ActiveRecord::Base

  def self.add_admin_tag_id(user_id,admin_id)
    tags = AdminTag.where(user_id: admin_id).where.not(name:["other"])
    tags.each do |tag|
      tag_array = []
      tag_array = tag.name.split
      schedules = self.ransack(summary_cont_any: tag_array).result
      schedules.update_all(tag_id: tag.id)
   end
   schedules = self.all.where(user_id: user_id)
   schedules.each do |s|
     if s.tag_id == nil
       s.tag_id = AdminTag.where(user_id: admin_id).find_by(name:"other").id
       s.save
     end
   end
 end

   def self.admin_month_sum_work_time(user_id,admin_id)
     tags = AdminTag.all.where(user_id: admin_id).order(created_at: :desc)
     tags.each do |tag|
      sum = 0
      schedules = AdminSchedule.where(tag_id: tag.id).where(user_id: user_id)
       schedules.each do |schedule|
        work_hours = (schedule.endtime-schedule.starttime)/3600
        sum += work_hours.to_i
      end
     tag.sum_time = sum
     end
   end

   def self.add_admin_day_id(user_id, admin_id)
     schedules = AdminSchedule.all.where(user_id: user_id)
     days = Day.all
     days.each do |day|
       schedules = AdminSchedule.where(year: day.year, month: day.month, day_month: day.day_month).where(user_id: user_id)
       schedules.update_all(day_id: day.id)
     end
   end
end

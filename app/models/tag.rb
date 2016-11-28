class Tag < ActiveRecord::Base
 belongs_to :user

　


 def self.calc_work_time(project_name)
  summaries = Tag.where("summary like '%"+project_name+"%'")

  sum = 0
  summaries.each do |summary|
    work_hours = (summary.endtime-summary.starttime)/3600
    sum += work_hours.to_i
  end
  sum
 end
end

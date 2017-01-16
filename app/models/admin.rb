class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :trackable, :validatable

         def self.sort_user_by_project(year,month,name,time,admin_id)
           schedules = AdminSchedule.all.where(year: year, month: month)
           users = User.all
           sort_users = []
           users.each do |user|
             month_sum_time_tag = schedules.admin_month_sum_work_time(user.id,admin_id)
              month_sum_time_tag.each do |s|
               if s.name.include?(name)
                 if s.sum_time.to_i > time.to_i
                   temp_user = {}
                   temp_user = {id: user.id,name: user.name,email: user.email,picture: user.picture, year: year,month: month,project_name: name,project_spend_time: s.sum_time,set_time: time}
                   sort_users.push(temp_user)
                 end
               end
             end
           end
           return sort_users
         end
end

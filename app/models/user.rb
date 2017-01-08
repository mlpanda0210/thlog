class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:google_oauth2]

         has_many :tags
         has_many :schedules

         def self.find_for_google_oauth2(auth)
           user = User.where(email: auth.info.email).first
           unless user
             user = User.create(name:     auth.info.name,
                                provider: auth.provider,
                                uid:      auth.uid,
                                email:    auth.info.email,
                                picture:  auth.extra.raw_info.picture,
                                token:    auth.credentials.token,
                                refresh_token: auth.credentials.refresh_token,
                                password: Devise.friendly_token[0, 20])
           end
           user
         end

         def self.sort_user_by_project(year,month,name,time)
           schedules = Schedule.all.where(year: year, month: month)
           users = User.all
           sort_users = []
           users.each do |user|
             month_sum_time_tag = schedules.month_sum_work_time(user.id)
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

         def self.sort_user_by_working_time(year,month,time)
           schedules = Schedule.all.where(year: year, month: month)
           users = User.all
           sort_users = []
           users.each do |user|
             month_sum_time_tag = schedules.month_sum_work_time(user.id)
             month_total_sum_time = 0
              month_sum_time_tag.each do |s|
                month_total_sum_time += s.sum_time.to_i
              end
              if month_total_sum_time.to_i > time.to_i
                temp_user = {}
                temp_user = {id: user.id,name: user.name,email: user.email,picture: user.picture, year: year,month: month,total_spend_time: month_total_sum_time,set_time: time}
                sort_users.push(temp_user)
              end
           end
           return sort_users
         end
       end

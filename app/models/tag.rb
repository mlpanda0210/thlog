class Tag < ActiveRecord::Base
 belongs_to :user
 has_many :schedules

 def self.add_tags(projects, user_id)
   projects.each do |project|
     self.create(name: project, user_id: user_id)
   end
 end
end

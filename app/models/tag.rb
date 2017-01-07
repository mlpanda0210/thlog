class Tag < ActiveRecord::Base
 belongs_to :user
 has_many :schedules
 validates :name, presence: true
 validates :description, presence: true


 def self.add_tags(projects_name, projects_description, user_id)
   self.find_or_create_by(name: "other",description: "その他", user_id: user_id)

   projects_name.each_with_index do |name, i|
     description = projects_description[i]
     self.create(name: name, description: description, user_id: user_id)
   end
  end
 end

class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.integer :user_id
      t.integer :tag_id
      t.string :tag
      t.string :summary
      t.string :description
      t.timestamp :starttime
      t.timestamp :endtime

      t.timestamps null: false
    end
  end
end

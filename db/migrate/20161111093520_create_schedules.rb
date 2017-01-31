class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.integer :user_id
      t.integer :tag_id
      t.integer :day_id
      t.string :summary
      t.string :description
      t.timestamp :starttime
      t.timestamp :endtime
      t.float :spendtime
      t.integer :year
      t.integer :month
      t.integer :day_month
      t.string :event_id
      t.timestamps null: false
    end
  end
end

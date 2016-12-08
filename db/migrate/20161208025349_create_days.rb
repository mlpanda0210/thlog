class CreateDays < ActiveRecord::Migration
  def change
    create_table :days do |t|
      t.integer :year
      t.integer :month
      t.integer :day_month
      t.string :schedule_summary
      t.string :schedule_description
      t.timestamp :schedule_starttime
      t.timestamp :schedule_endtime

      t.timestamps null: false
    end
  end
end

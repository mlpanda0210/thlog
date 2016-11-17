class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.string :summary
      t.string :description
      t.timestamp :starttime
      t.timestamp :endtime

      t.timestamps null: false
    end
  end
end

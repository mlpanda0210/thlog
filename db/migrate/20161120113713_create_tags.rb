class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.integer :user_id
      t.string :summary
      t.string :description
      t.timestamp :starttime
      t.timestamp :endtime

      t.timestamps null: false
    end
  end
end

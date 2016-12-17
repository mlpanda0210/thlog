class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.string :description
      t.integer :user_id
      t.integer :sum_time
      t.timestamps null: false
    end
  end
end

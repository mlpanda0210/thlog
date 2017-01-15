class AddOmniauthToAdmin < ActiveRecord::Migration
  def change
    add_column :admins, :provider, :string
    add_column :admins, :uid, :string
    add_column :admins, :name, :string
    add_column :admins, :picture, :string
    add_column :admins, :token, :string
    add_column :admins, :refresh_token, :string
    add_column :admins, :access_token, :string
  end
end

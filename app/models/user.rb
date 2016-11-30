class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:google_oauth2]

         has_many :tags
         has_many :schedules


         def self.find_for_google_oauth2(auth)
             user = User.where(email: auth.info.email).first
             unless user
               user = User.create(name:     auth.info.name,
                                  provider: auth.provider,
                                  uid:      auth.uid,
                                  email:    auth.info.email,
                                  token:    auth.credentials.token,
                                  refresh_token: auth.credentials.refresh_token,
                                  password: Devise.friendly_token[0, 20])
             end
             user
           end
         end

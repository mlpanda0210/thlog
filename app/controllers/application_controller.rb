class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    if admin_signed_in?
      admin_admin_index_path
    else
      Tag.find_or_create_by(name: "other",description: "その他", user_id: current_user.id)
      Schedule.update_schedule(current_user)
      gcales_path
    end
  end
end

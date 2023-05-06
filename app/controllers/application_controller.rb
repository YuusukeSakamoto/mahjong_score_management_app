class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

    # ユーザー登録時にnameもDB保存する
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :avatar, :member_id])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :admin_flag, :avatar, :member_id])
  end
  
end

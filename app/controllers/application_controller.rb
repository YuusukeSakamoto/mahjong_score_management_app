class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :current_player
  
  private
      # ユーザー登録時にnameもDB保存する
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :avatar])
      devise_parameter_sanitizer.permit(:account_update, keys: [:name, :admin_flag, :avatar])
    end
    
    def current_player
      @player = current_user.player  if user_signed_in?
    end
    

end

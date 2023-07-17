class ApplicationController < ActionController::Base
  include ApplicationHelper
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :current_player
  
  # sessionからmatch_groupとruleとleagueを削除し、match_groupを確定させる
  def end_record
    session[:mg] = nil 
    session[:rule] = nil
    session[:league] = nil
  end
  
  private
      # ユーザー登録時にnameもDB保存する
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :avatar])
      devise_parameter_sanitizer.permit(:account_update, keys: [:name, :admin_flag, :avatar])
    end
    
end

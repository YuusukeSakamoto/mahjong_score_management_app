class ApplicationController < ActionController::Base
  include ApplicationHelper
  
  TOKEN_ENABLED_TIME = 15 # プレイヤー選択におけるトークンの有効期限（分）
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :current_player #ApplicationHelperに記載
  
  # sessionからmatch_group/rule/league/playersを削除し、match_groupを確定させる
  def end_record
    session[:mg] = nil 
    session[:rule] = nil
    session[:league] = nil
    session[:players] = nil
  end
  
    # flash[:alert]をセットし、ルートパスへリダイレクトする
  def set_alert_redirect_root(message)
    flash[:alert] = message
    redirect_to root_path and return
  end
  
  private
      # ユーザー登録時にnameもDB保存する
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :avatar])
      devise_parameter_sanitizer.permit(:account_update, keys: [:name, :admin_flag, :avatar])
    end
    
end

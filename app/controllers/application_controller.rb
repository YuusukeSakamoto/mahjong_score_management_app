class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :current_player
  
  # ログインユーザーに紐づくプレイヤーを取得する
  def current_player
    if user_signed_in?
      @player = current_user.player 
    else
      @player = Player.find(1) # 仮ユーザー
    end
  end
  
  private
      # ユーザー登録時にnameもDB保存する
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :avatar])
      devise_parameter_sanitizer.permit(:account_update, keys: [:name, :admin_flag, :avatar])
    end
    
end

# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in

  # POST /resource/sign_in

  # DELETE /resource/sign_out

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  end

  # ログイン後のリダイレクト先を指定
  # プレイヤー選択時のユーザー認証時 → 認証完了ページ
  # 通常ログイン時　→ トップページ
  def after_sign_in_path_for(_resource)
    if params[:user][:u_id].present?
      user = User.find_by(id: params[:user][:u_id])
      if user.present?
        tk = user.player_select_token
        players_authentications_path(tk: tk)
      else
        flash[:alert] = '認証に失敗しました'
        root_path
      end
    else
      root_path
    end
  end
end

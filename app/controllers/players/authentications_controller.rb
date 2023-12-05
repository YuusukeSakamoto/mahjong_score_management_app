# frozen_string_literal: true

class Players::AuthenticationsController < ApplicationController
  def index
    redirect_to(new_user_session_path(u_id: params[:u_id])) && return unless user_signed_in?

    player_select_token = params[:tk]
    user = User.find_by(player_select_token: player_select_token)
    if user && user.player_select_token_created_at > TOKEN_ENABLED_TIME.minutes.ago
      # URLが有効で、有効期限内の場合
      # 認証URLを発行したユーザーのidを入れる
      @token_issued_user_name = user.name
      current_user.update(token_issued_user: user.id)
      flash[:notice] = '認証が完了しました'
    else
      # URLが無効または有効期限切れの場合
      redirect_to root_path, alert: FlashMessages::INVALID_OR_EXPIRED_URL
    end
  end
end

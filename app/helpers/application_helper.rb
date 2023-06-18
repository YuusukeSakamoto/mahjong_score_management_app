module ApplicationHelper
  # ログインユーザーに紐づくプレイヤーを取得する
  def current_player
    if user_signed_in?
      @player = current_user.player 
    else
      @player = Player.find(1) # 仮ユーザー
    end
  end
end

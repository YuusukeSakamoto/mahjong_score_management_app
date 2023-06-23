module ApplicationHelper
  # ログインユーザーに紐づくプレイヤーを取得する
  def current_player
    if user_signed_in?
      @player = current_user.player
    else
      @player = Player.find(1) # 仮ユーザー
    end
  end
  
  # 漢数字に変換する
  def conversion_kanji_num(num)
    case num
    when 3
      '三'
    when 4
      '四'
    end
  end
  
  # セッションに格納されているプレイヤー数を取得する
  def session_player_num
    session[:players].count
  end

end

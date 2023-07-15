module ApplicationHelper
  # ログインユーザーに紐づくプレイヤーを取得する
  def current_player
    current_user&.player || Player.find(1) # 仮ユーザー
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
  def session_players_num
    session[:players]&.count
  end
  
  # セッションに格納されているmatch_groupを取得する
  def set_session_match_group
    MatchGroup.find(session[:mg])
  end
  
  # 成績記録中か真偽値で返す
  def recording?
    session[:mg].present?
  end
  
  # リーグ成績記録中か真偽値で返す
  def league_recording?
    session[:league].present?
  end
  
end

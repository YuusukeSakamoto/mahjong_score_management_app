module ApplicationHelper
  # ログインユーザーに紐づくプレイヤーを取得する
  def current_player
    current_user&.player
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
  def set_match_group_by_session
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

  # ポイントの表示形式を編集して返す
  def show_pt(point, rule_id)
    is_decimal_point_valid = (Rule.find(rule_id).score_decimal_point_calc == 1)
    # 小数点なしルールの場合、小数点を削除する
    point = point.to_i unless is_decimal_point_valid

    if point.positive?
      "+#{point}" # 正の値の場合はプラス記号を付ける
    elsif point.negative?
      point.to_s # 負の値の場合はそのまま文字列として返す
    else
      is_decimal_point_valid ? "0.0" : "0" # ゼロの場合は小数点なしルールかどうかで表示形式を変える
    end
  end

  # 対局の削除ボタンクリック時の確認メッセージ
  def delete_confirm_message(mg)
    if mg.matches.count == 1 && mg.rule.is_chip
      "対局成績を削除しますか？(チップ成績も削除されます)"
    else
      "対局成績を削除しますか？"
    end
  end

  # idからルール名を返す
  def rule_name(id)
    Rule.find_by(id: id).name
  end

  # idからリーグ名を返す
  def league_name(id)
    League.find_by(id: id).name
  end

end
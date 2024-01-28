# frozen_string_literal: true

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
    rule = Rule.find(rule_id)
    is_decimal_point_valid = (rule.score_decimal_point_calc == 1)
    # 小数点なしルールの場合、小数点を削除する
    point = point.to_i unless is_decimal_point_valid

    if point.positive?
      "+#{point}" # 正の値の場合はプラス記号を付ける
    elsif point.negative?
      point.to_s # 負の値の場合はそのまま文字列として返す
    end

    if point == '0.0'
      point = is_decimal_point_valid ? '0.0' : '0' # ゼロの場合は小数点なしルールかどうかで表示形式を変える
    end

    point
  end

  # 対局の削除ボタンクリック時の確認メッセージ
  def delete_confirm_message(mg)
    if mg.matches.count == 1 && mg.rule.is_chip
      '対局成績を削除しますか？(チップ成績も削除されます)'
    else
      '対局成績を削除しますか？'
    end
  end

  # idからルール名を返す
  def rule_name(rule_id)
    Rule.find_by(id: rule_id).name
  end

  # idからリーグ名を返す
  def league_name(league_id)
    League.find_by(id: league_id).name
  end

  # metaタグ定義
  def default_meta_tags
    {
      site: 'Janreco',
      title: 'Janreco - 簡単に麻雀成績を記録できる！(三麻/四麻対応)',
      reverse: true,
      charset: 'utf-8',
      description: 'Janreco(じゃんれこ)は、簡単に麻雀の対局成績を記録することができるサービスです。（四人/三人麻雀対応、チップ対応）成績を記録する人がユーザー登録すれば、プレイヤー全員分の対局成績を記録することができます。またリンクを共有することで対局成績を共有しながら麻雀を楽しむことができます。',
      keywords: '麻雀,成績記録,リーグ戦',
      canonical: request.original_url,
      separator: '|',
      icon: [
        { href: image_url('favicon.ico') },
        { href: image_url('apple-touch-icon.png'), rel: 'apple-touch-icon', sizes: '180x180', type: 'image/png' },
      ],
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: 'website',
        url: request.original_url,
        image: image_url('apple-touch-icon.png'),
        local: 'ja-JP',
      },
      twitter: {
        card: 'summary_large_image',
        site: '@',
        image: image_url('apple-touch-icon.png'),
      }
    }
  end
end

# frozen_string_literal: true

module FlashMessages
  # 全般
  ACCESS_DENIED = 'アクセス権限がありません'
  EDIT_DENIED = '編集権限がありません'
  UPDATE_DENIED = '更新権限がありません'
  DESTROY_DENIED = '削除権限がありません'
  ERROR = 'エラーが発生しました'
  UNAUTHENTICATED = 'ログインもしくはアカウント登録してください'

  # user
  FAIED_TO_CREATE_USER = 'アカウント登録に失敗しました'

  # player
  FAIED_TO_SELECT_PLAYERS = 'プレイヤー選択でエラーが発生しました'
  UPDATE_PLAYER = 'プレイヤー名を更新しました'
  FAIED_TO_UPDATE_PLAYER = 'プレイヤー名の更新に失敗しました'
  FAIED_TO_DESTROY_PLAYER = 'プレイヤーの削除に失敗しました'

  # rule
  DELETION_PREVENTED_DUE_TO_ASSOCIATED_RECORDS = '指定したルールで記録した成績が存在するため、削除できません。'
  CANNOT_DESTROY = '削除できませんでした'
  CANNOT_CREATE_RULE_RECORDING = '記録中はルール登録できません'

  # match
  CREATE_MATCH = '対局成績を登録しました'
  UPDATE_MATCH = '対局成績を更新しました'
  DESTROY_MATCH = '対局成績を削除しました'
  MATCH_RESULTS_NOT_FOUND = '指定の対局成績が存在しません'
  RECORDING_NOW = '他の成績を記録中です'
  PLAYER_NOT_SELECTED = 'プレイヤーが選択されていません'
  FAIED_TO_CREATE_MATCH = '対局成績の登録に失敗しました'

  # match_group
  END_RECORD = '記録を終了しました'
  DESTROY_MATCH_GROUP = '対局成績表を削除しました'

  # chip_result
  CHIP_RESULTS_NOT_FOUND = 'チップ成績が存在しません'
  CHIP_EDIT_DENIED = 'チップ有ルールでないため、編集できません'
  CHIP_UPDATE_DENIED = 'チップ有ルールでないため、更新できません'

  # league
  FAILED_TO_CREATE_LEAGUE = 'リーグ作成に失敗しました'
  FAILED_TO_DESTROY_LEAGUE = 'リーグ削除に失敗しました'
  CANNOT_RECORD_LEAGUE = 'リーグ主催者でないため、記録できません'
  CANNOT_EDIT_LEAGUE = 'リーグ主催者でないため、編集できません'
  CANNOT_UPDATE_LEAGUE = 'リーグ主催者でないため、更新できません'
  CANNOT_DESTROT_LEAGUE = 'リーグ主催者でないため、削除できません'
  CANNOT_CREATE_LEAGUE_RECORDING = '記録中はリーグ作成できません'

  # players/authentications
  INVALID_OR_EXPIRED_URL = 'URLが無効または有効期限切れです。'

  # users/registrations
  INVALID_LINK = '無効なリンクです。リンク発行者に再発行をお願いしてください'
  EXPIRED_LINK = '期限切れです。リンク発行者に再発行をお願いしてください'

  def self.player_flash(player_name, action)
    case action
    when 'destroy'
      "プレイヤー : #{player_name}を削除しました"
    end
  end

  def self.rule_flash(rule_name, action)
    case action
    when 'create'
      "ルール : #{rule_name}を登録しました"
    when 'update'
      "ルール : #{rule_name}を更新しました"
    when 'destroy'
      "ルール : #{rule_name}を削除しました"
    end
  end

  def self.league_flash(league_name, action)
    case action
    when 'create'
      "リーグ : #{league_name}を登録しました"
    when 'update'
      "#{league_name}のリーグ情報を更新しました"
    when 'destroy'
      "リーグ : #{league_name}を削除しました"
    end
  end
end

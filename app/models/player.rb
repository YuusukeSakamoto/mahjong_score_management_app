class Player < ApplicationRecord
  validates :name, {presence: true, length: {maximum: 10}}
  validates :invite_token, uniqueness:true, allow_nil: true
  
  belongs_to :user, optional: true #optional:trueで外部キーがnilでもDB登録できる
  has_many :rules ,dependent: :destroy #playerに紐づいたrulesも削除される
  has_many :matches 
  has_many :results 
  
  attr_accessor :invite_token, :match_ids
  
  HYPHENS = [' - ',' - ',' - ',' - ']
  HYPHEN = ' - '
  OFTEN_PLAYERS_NUM = 5
  
  def self.get_name(id)
    Player.find(id).name
  end
  
  def self.get_players_name(results)
    players_name = results.map{ |result| Player.find(result.player_id).name }
    players_name << HYPHEN if results.count == 3
    return players_name
  end

  #************************************
  # メインデータ
  #************************************

  # playerの総対局数を取得する
  def total_match_count
    results.where(match_id: match_ids).count
  end
  
  # playerの総合ptを取得する
  def total_point
    sprintf("%+.1f", results.where(match_id: match_ids).sum(:point))
  end
  
  # playerの平均順位を取得する
  def average_rank
    return HYPHEN if results.where(match_id: match_ids).count == 0
    sprintf("%.2f",results.where(match_id: match_ids).sum(:point) / total_match_count.to_f)
  end
  
  # playerの連対率を取得する
  def rentai_rate
    return ' - ' if results.where(match_id: match_ids).count == 0
    sprintf("%.2f", (results.where(match_id: match_ids).where(rank: [1, 2]).count / total_match_count.to_f) * 100)
  end
  
  #************************************
  # 順位別データ
  #************************************
  # 順位別データを配列にまとめる
  def rank_results(play_type)
    rank_results = [rank_rate, rank_times].transpose
    rank_results.pop if play_type == 3 #三麻の場合、4位の結果を消去する
    return rank_results
  end
  
  # playerの各順位率を取得する
  def rank_rate
    return HYPHENS if rank_times.sum == 0
    rank_times.map do |rank_time|
      sprintf("%.1f", (rank_time / total_match_count.to_f) * 100)
    end
  end
  
  # playerの各順位回数を取得する
  def rank_times
    Result::RANK_NUM.map do |rank|
      results.where(match_id: match_ids).where(rank: rank).count
    end
  end
  
  #************************************
  # 家別データ
  #************************************
  # 家別データを配列にまとめる
  def ie_results
    [average_rank_by_ie, ie_times, total_point_by_ie].transpose
  end

  # 家別の平均順位を取得する
  def average_rank_by_ie
    ie_times.map.with_index do |ie_time, i|
      next HYPHEN if ie_time == 0
      sprintf("%.1f", (results.where(ie: i + 1).sum(:point) / ie_time.to_f))
    end
  end
  
  # 家別の対局数を取得する
  def ie_times
    Result::IE_NUM.map do |ie|
      results.where(match_id: match_ids).where(ie: ie).count
    end
  end

  # 家別のptを取得する
  def total_point_by_ie
    Result::IE_NUM.map do |ie|
      sprintf("%+.1f", results.where(match_id: match_ids).where(ie: ie).sum(:point))
    end
  end
  
  #************************************
  # よく遊ぶプレイヤーデータ
  #************************************
  
  # よく遊ぶプレイヤーと回数を取得する（５人まで）
  def often_play_times
    attended_match_ids = results.where(match_id: match_ids).pluck(:match_id)
    often_play_players = Result.where(match_id: attended_match_ids)
                                  .where.not(player_id: id)
                                  .group(:player_id)
                                  .order('count_player_id DESC')
                                  .limit(OFTEN_PLAYERS_NUM)
                                  .count(:player_id)
                                  .to_a
    
    return often_play_players if often_play_players.count >= OFTEN_PLAYERS_NUM
    # 五人いない場合はハイフンで埋める
    (OFTEN_PLAYERS_NUM - often_play_players.count).times do 
      often_play_players << [HYPHEN, 0]  
    end
    often_play_players
  end
  
  #************************************
  # ユーザー招待リンク用
  #************************************
  
  # current_playerから該当プレイヤーが招待可能か真偽値を返す
  def can_invite?(current_player)
    is_recorded_by_current_player?(current_player) && self.user_id.nil?
  end
  
  # 招待トークンを発行してDB保存する
  def create_invite_token
    self.invite_token = SecureRandom.urlsafe_base64
    update_columns(invite_token: invite_token ,invite_create_at: Time.zone.now)
  end

  # current_playerが記録をつけたプレイヤーか真偽値を返す
  def is_recorded_by_current_player?(current_player)
    recorded_match_ids = current_player.matches.pluck(:id) # current_playerが記録した対局idを配列で取得
    Result.where(match_id: recorded_match_ids).where.not(player_id: current_player.id)
      .select(:player_id).distinct.pluck(:player_id).include?(id)
  end
  
  #************************************
  # 登録したルール
  #************************************
  
  # プレイヤーが登録したルール数を取得する
  def rules_num
    rules.where(play_type: session_player_num).count
  end
  
  # 登録した四人麻雀or三人麻雀ルールをすべて取得する
  def rule_list(play_type)
    rules.where(play_type: play_type)
  end
  
end

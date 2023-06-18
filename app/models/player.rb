class Player < ApplicationRecord
  validates :name, {presence: true, length: {maximum: 10}}
  validates :invite_token, uniqueness:true
  
  belongs_to :user, optional: true #optional:trueで外部キーがnilでもDB登録できる
  has_many :rules ,dependent: :destroy #playerに紐づいたrulesも削除される

  has_many :matches 
  has_many :results 
  
  attr_accessor :invite_token
  
  HYPHEN = [' - ',' - ',' - ',' - ']

  def get_player_name(id)
    Player.find(id).name
  end
  
  def self.get_players_name(results)
    players_name = results.map{ |result| Player.find(result.player_id).name }
    players_name << "-" if results.count == 3
    return players_name
  end

  #************************************
  # メインデータ
  #************************************

  # playerの総対局数を取得する
  def total_match_count
    results.count
  end
  
  # playerの総合ptを取得する
  def total_point
    sprintf("%+.1f", results.pluck(:point).sum)
  end
  
  # playerの平均順位を取得する
  def average_rank
    return ' - ' if results.count == 0
    sprintf("%.2f",results.pluck(:rank).sum / total_match_count.to_f)
  end
  
  # playerの連対率を取得する
  def rentai_rate
    return ' - ' if results.count == 0
    sprintf("%.2f", (results.where(rank: [1, 2]).count / total_match_count.to_f) * 100)
  end
  
  #************************************
  # 順位別データ
  #************************************
  
  # playerの各順位率を取得する
  def rank_rate
    return HYPHEN if rank_times.sum == 0
    rank_times.map do |rank_time|
      sprintf("%.1f", (rank_time / total_match_count.to_f) * 100)
    end
  end
  
  # playerの各順位回数を取得する
  def rank_times
    Result::RANK_NUM.map do |rank|
      results.where(rank: rank).count
    end
  end
  
  #************************************
  # 家別データ
  #************************************

  # 家別の平均順位を取得する
  def average_rank_by_ie
    ie_times.map.with_index do |ie_time, i|
      next '-' if ie_time == 0
      sprintf("%.1f", (results.where(ie: i + 1).pluck(:rank).sum / ie_time.to_f))
    end
  end
  
  # 家別の対局数を取得する
  def ie_times
    Result::IE_NUM.map do |ie|
      results.where(ie: ie).count
    end
  end

  # 家別のptを取得する
  def total_point_by_ie
    Result::IE_NUM.map do |ie|
      sprintf("%+.1f", results.where(ie: ie).pluck(:point).sum)
    end
  end
  
  #************************************
  # よく遊ぶプレイヤーデータ
  #************************************
  
  # よく遊ぶプレイヤーと回数を取得する（５人まで）
  def often_play_times
    attended_match_ids = results.pluck(:match_id)
    Result.where(match_id: attended_match_ids).where.not(player_id: id)
      .group(:player_id).order('count_player_id DESC').count(:player_id).to_a.first(5)
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
  
end

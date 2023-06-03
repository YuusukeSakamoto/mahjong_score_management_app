class Result < ApplicationRecord
  belongs_to :player
  belongs_to :match
  
  # ★ 要らない
  # accepts_nested_attributes_for :match #resultも同時に保存できるようになる
  
  # ★ 追記
  validates :score, presence: true
  validates :point, presence: true
  # validates :ie, presence: true
  validates :ie, presence: true, uniqueness: { scope: :match_id }
  # validate :not_allow_same_ie
  
  # ★ matchから移動
  IE = [["東",1], ["南", 2], ["西",3], ["北", 4]]
  IE_NUM = [1, 2, 3, 4]  
  RANK_NUM = [1, 2, 3, 4]
  YONMA_TIMES = 4
  SANMA_TIMES = 3

  #************************************
  # メインデータ
  #************************************

  # playerの総対局数を取得する
  def self.get_total_match_count(player_id)
    Result.where(player_id: player_id).count
  end
  
  # playerの平均順位を取得する
  def self.get_average_rank(player_id)
    sprintf("%.2f", 
      Result.where(player_id: player_id).pluck(:rank).sum / Result.get_total_match_count(player_id).to_f
    )
  end

  
  # playerの総合ptを取得する
  def self.get_total_point(player_id)
    sprintf("%+.1f", 
      Result.where(player_id: player_id).pluck(:point).sum
    )
  end
  
  # playerの連対率を取得する
  def self.get_rentai_rate(player_id)
    sprintf("%.2f", 
      (Result.where(player_id: player_id).where(rank: [1, 2]).count / Result.get_total_match_count(player_id).to_f) * 100  
    )
  end
  
  #************************************
  # 順位別データ
  #************************************
  
  # playerの各順位率を取得する
  def self.get_rank_rate(player_id)
    Result.get_rank_times(player_id).map do |rank_time|
      sprintf("%.1f", (rank_time / Result.get_total_match_count(player_id).to_f) * 100)
    end
  end
  
  # playerの各順位回数を取得する
  def self.get_rank_times(player_id)
    RANK_NUM.map do |rank|
      Result.where(player_id: player_id).where(rank: rank).count
    end
  end
  
  #************************************
  # 家別データ
  #************************************

  # 家別の平均順位を取得する
  def self.get_average_rank_by_ie(player_id)
    Result.get_ie_times(player_id).map.with_index do |ie_time, i|
      next '-' if ie_time == 0
      sprintf("%.1f", 
        ( Result.where(player_id: player_id).where(ie: i + 1).pluck(:rank).sum / ie_time.to_f )
      )
    end
  end
  
  # 家別の対局数を取得する
  def self.get_ie_times(player_id)
    IE_NUM.map do |ie|
      Result.where(player_id: player_id).where(ie: ie).count
    end
  end

  # 家別のptを取得する
  def self.get_total_point_by_ie(player_id)
    IE_NUM.map do |ie|
      sprintf("%+.1f", 
        Result.where(player_id: player_id).where(ie: ie).pluck(:point).sum
      )
    end
  end
  
  #************************************
  # よく遊ぶプレイヤーデータ
  #************************************
  
  # よく遊ぶプレイヤーと回数を取得する（５人まで）
  def self.get_often_play_times(player_id)
    match_ids = Result.where(player_id: player_id).pluck(:match_id)
    Result.where(match_id: match_ids).where.not(player_id: player_id)
      .group(:player_id).order('count_player_id DESC').count(:player_id).to_a.first(5)
  end

  
  private
  
    def not_allow_same_ie
      # byebug
    end

  
end

class Match < ApplicationRecord
  belongs_to :player
  belongs_to :rule
  has_many :results ,dependent: :destroy #matchに紐づいたresultsも削除される
  accepts_nested_attributes_for :results #resultも同時に保存できるようになる
  
  validates :play_type, presence: true, numericality: { in: 3..4 }
  validates :match_on, presence: true

  scope :desc, -> { order(match_on: :desc) } #対局日付の降順
  scope :asc, -> { order(match_on: :asc) } #対局日付の降順
  scope :sanma, -> (match_ids){ where(id: match_ids).where(play_type: 3) } #三麻のmatch_idを配列で格納
  scope :yonma, -> (match_ids){ where(id: match_ids).where(play_type: 4) } #四麻のmatch_idを配列で格納
  scope :league, -> (mg_ids){ where(match_group_id: mg_ids).asc } #リーグ対局をすべて取得する

  # ログインユーザーの該当対局のポイントを取得する
  def current_player_point(id)
    results.find_by(player_id: id).point
  end
  
end
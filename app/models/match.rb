class Match < ApplicationRecord
  belongs_to :player
  belongs_to :rule
  has_many :results ,dependent: :destroy #matchに紐づいたresultsも削除される
  accepts_nested_attributes_for :results #resultも同時に保存できるようになる
  
  validates :player_num, presence: true, numericality: { in: 3..4 }
  validates :player_id, :rule_id, :match_on, presence: true

  scope :desc, -> { order(created_at: :desc) } #作成の降順
  scope :sanma, -> (match_ids){ where(id: match_ids).where(player_num: 3)  } ##三麻のmatch_idを配列で格納
  scope :yonma, -> (match_ids){ where(id: match_ids).where(player_num: 4)  } ##三麻のmatch_idを配列で格納

  # ログインユーザーの該当対局のポイントを取得する
  def current_player_point(id)
    results.find_by(player_id: id).point
  end
  
end
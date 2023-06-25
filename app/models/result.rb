class Result < ApplicationRecord
  belongs_to :player
  belongs_to :match
  
  validates :score, presence: true, numericality: { only_integer: true }
  validates :point, presence: true
  validates :ie, presence: true

  scope :match_ids, -> (p_id){ where(player_id: p_id).pluck(:match_id) } #プレイヤーが参加したすべてのmatch_idを配列で格納
  
  IE = [["東",1], ["南", 2], ["西",3], ["北", 4]]
  IE_NUM = [1, 2, 3, 4]  
  RANK_NUM = [1, 2, 3, 4]
  YONMA_TIMES = 4
  SANMA_TIMES = 3

end

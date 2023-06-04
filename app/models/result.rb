class Result < ApplicationRecord
  belongs_to :player
  belongs_to :match
  
  validates :score, presence: true, numericality: { only_integer: true }
  validates :point, presence: true
  validates :ie, presence: true
  
  IE = [["東",1], ["南", 2], ["西",3], ["北", 4]]
  IE_NUM = [1, 2, 3, 4]  
  RANK_NUM = [1, 2, 3, 4]
  YONMA_TIMES = 4
  SANMA_TIMES = 3

end

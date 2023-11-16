class ChipResult < ApplicationRecord
  belongs_to :match_group
  
  validates :number, :point,  presence: true
  
  # scope :asc, -> { order(match_on: :asc) } #対局日付の降順
  # scope :league, -> (mg_ids){ where(match_group_id: mg_ids).asc } #リーグ対局のchip_resultをすべて取得する
end

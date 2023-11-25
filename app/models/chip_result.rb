class ChipResult < ApplicationRecord
  belongs_to :match_group
  
  validates :number, :point,  presence: true
  
end
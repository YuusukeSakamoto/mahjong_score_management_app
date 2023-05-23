class Result < ApplicationRecord
  belongs_to :player
  belongs_to :match
  
  accepts_nested_attributes_for :match #resultも同時に保存できるようになる
  
end

class Match < ApplicationRecord
  belongs_to :player
  belongs_to :rule
  has_many :results ,dependent: :destroy #matchに紐づいたresultsも削除される
  accepts_nested_attributes_for :results #resultも同時に保存できるようになる
  
  validates :match_on, presence: true

end
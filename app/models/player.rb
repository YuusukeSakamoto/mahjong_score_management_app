class Player < ApplicationRecord
  validates :name, presence: true
  
  belongs_to :user
  
  
  # def self.member_id
  #   Player.last.id + 329
  # end
  
  def self.user_id
    Player.find().user.id
  end
end

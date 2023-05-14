class Player < ApplicationRecord
  validates :name, presence: true
  
  belongs_to :user, optional: true #optional:trueで外部キーがnilでもDB登録できる
  has_many :rules ,dependent: :destroy #playerに紐づいたrulesも削除される
  has_many :results ,dependent: :destroy #playerに紐づいたresultsも削除される

  # def self.players
  #   params[:players]
  # end
  # def self.member_id
  #   Player.last.id + 329
  # end
  
  # def self.user_id
  #   Player.find().user.id
  # end
end

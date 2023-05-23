class Player < ApplicationRecord
  validates :name, presence: true
  
  belongs_to :user, optional: true #optional:trueで外部キーがnilでもDB登録できる
  has_many :rules ,dependent: :destroy #playerに紐づいたrulesも削除される
  has_many :results ,dependent: :destroy #playerに紐づいたresultsも削除される

end

class User < ApplicationRecord

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :groups, dependent: :destroy #userに紐づいたtrainingも削除される
  
  validates :name, presence: true
  
end

class User < ApplicationRecord

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  mount_uploader :avatar, ImageUploader #アップローダークラスと画像を格納するカラムを紐付け
         
  has_one :player

  validates :name, presence: true
  
  
end

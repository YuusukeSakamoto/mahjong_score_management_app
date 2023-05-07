class User < ApplicationRecord

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  mount_uploader :avatar, ImageUploader #アップローダークラスと画像を格納するカラムを紐付け
         
  has_one :player
  # has_many :group_users
  # has_many :groups, through: :group_users, dependent: :destroy #userに紐づいたtrainingも削除される

  validates :name, presence: true
  
  
  def self.member_id
    User.last.id + 329
  end
  
end

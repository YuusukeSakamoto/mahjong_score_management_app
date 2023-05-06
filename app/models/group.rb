class Group < ApplicationRecord
  has_many :group_users
  has_many :users, through: :group_users

  validates :user_id, presence: true
  validates :name, presence: true
  validates :member_count, presence: true
  

  
end

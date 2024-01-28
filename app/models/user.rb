# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  mount_uploader :avatar, ImageUploader # アップローダークラスと画像を格納するカラムを紐付け

  has_one :player

  validates :name, presence: true, length: { maximum: 8 }

  enum role: { general: 0, admin: 1 }

  # ************************************
  # ユーザー招待リンク用
  # ************************************
  def generate_authentication_url
    self.player_select_token = SecureRandom.urlsafe_base64
    update_columns(player_select_token: player_select_token,
                   player_select_token_created_at: Time.zone.now)
  end
end

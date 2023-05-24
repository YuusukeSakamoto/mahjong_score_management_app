class Result < ApplicationRecord
  belongs_to :player
  belongs_to :match
  
  # ★ 要らない
  # accepts_nested_attributes_for :match #resultも同時に保存できるようになる
  
  # ★ 追記
  validates :score, presence: true
  validates :point, presence: true
  # validates :ie, presence: true
  validates :ie, presence: true, uniqueness: { scope: :match_id }
  # validate :not_allow_same_ie
  
  # ★ matchから移動
  IE = [["東",1], ["南", 2], ["西",3], ["北", 4]]

  private
  
    def not_allow_same_ie
      # byebug
    end

  
end

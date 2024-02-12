# frozen_string_literal: true

class Rule < ApplicationRecord
  belongs_to :player
  has_many :results

  validates :play_type, presence: true, inclusion: { in: [3, 4] }
  validates :name, presence: true, uniqueness: { scope: :player }, length: { maximum: 15 }
  validates :mochi, :kaeshi, :uma_one, :uma_two, :uma_three, :uma_four, :score_decimal_point_calc, presence: true
  validates :is_chip, inclusion: [true, false] # boolean型のpresenceチェック
  validates :chip_rate, presence: true, if: :is_chip # チップ有のときchip_rateが空でないか
  validates :chip_rate, absence: true, unless: :is_chip # チップ無のときchip_rateが空であるか
  validates :description, length: { maximum: 50 }
  validate :mochi_kaeshi_check


  scope :sanma, ->(p_id) { where(player_id: p_id).where(play_type: 3) }
  scope :yonma, ->(p_id) { where(player_id: p_id).where(play_type: 4) }

  # 小数点計算方法のコード値を返す
  def self.get_value_score_decimal_point_calc(score_decimal_point_calc)
    case score_decimal_point_calc
    when 1
      '小数点有効'
    when 2
      '五捨六入'
    when 3
      '四捨五入'
    when 4
      '切り捨て'
    when 5
      '切り上げ'
    end
  end

  # チップ有無のコード値を返す
  def self.get_value_is_chip(is_chip)
    is_chip ? '有' : '無'
  end

  # チップpt/枚のコード値を返す
  def self.get_value_chip_rate(chip_rate)
    chip_rate.nil? ? '-' : "#{chip_rate}pt"
  end

  # ----------------------
  # カスタムバリデーション
  # ----------------------
  # 持ち点>返し点の場合、エラー
  def mochi_kaeshi_check
    if mochi.present? && kaeshi.present?
      errors.add(:kaeshi, '点は持ち点より大きくしてください') if mochi > kaeshi
    end
  end
end

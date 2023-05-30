class Rule < ApplicationRecord
  belongs_to :player
  has_many :results
  
  validates :name, presence: true, uniqueness: { scope: :player }
  validates :mochi, :kaeshi, :uma_1, :uma_2, :uma_3, :uma_4, :score_decimal_point_calc, presence: true
  validates :is_chip, inclusion: [true, false] # boolean型のpresenceチェック
  validates :chip_rate, presence: true, if: :is_chip #チップ有のときchip_rateが空でないか
  validates :chip_rate, absence: true, unless: :is_chip #チップ無のときchip_rateが空であるか

  # 小数点計算方法のコード値を返す
  def self.get_value_score_decimal_point_calc(score_decimal_point_calc)
    case score_decimal_point_calc
      when 1 then
        '計算しない'
      when 2 then
        '五捨六入'
      when 3 then
        '四捨五入'
      when 4 then
        '切り捨て'
      when 5 then
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
   
end

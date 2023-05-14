class Rule < ApplicationRecord
  belongs_to :player
  has_many :results
  
  validates :name, :mochi, :kaeshi, :uma_1, :uma_2, :uma_3, :uma_4, :score_decimal_point_calc, :chip_existence_flag, presence: true
  validates :chip_rate, presence: true, if: :chip_existence_flag_1? #チップ有のときchip_rateが空でないか
  validates :chip_rate, absence: true, if: :chip_existence_flag_2? #チップ無のときchip_rateが空であるか
  # validate :not_allow_same_rule_name

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
  def self.get_value_chip_existence_flag(chip_existence_flag)
    case chip_existence_flag
      when 1 then
        '有'
      when 2 then
        '無'
    end
  end

  # チップpt/枚のコード値を返す
  def self.get_value_chip_rate(chip_rate)
    chip_rate.nil? ? '-' : "#{chip_rate}pt"
  end
  
  private
  
    def not_allow_same_rule_name
      # byebug
      if Rule.where(player_id: player_id, name: name).present?
        errors.add('既に同じルール名が登録されています')
      end
    end
    
    def chip_existence_flag_2?
      chip_existence_flag == 2
    end
    
    def chip_existence_flag_1?
      chip_existence_flag == 1
    end
   
end

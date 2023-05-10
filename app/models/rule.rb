class Rule < ApplicationRecord
  belongs_to :player
  
  validates :name, :mochi, :kaeshi, :uma_1, :uma_2, :uma_3, :uma_4, :score_decimal_point_calc, :chip_existence_flag, presence: true
  validates :chip_rate, presence: true, if: :chip_existence_flag_1? #チップ有のときchip_rateが空でないか
  validates :chip_rate, absence: true, if: :chip_existence_flag_2? #チップ無のときchip_rateが空であるか
  # validate :not_allow_same_rule_name

  
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

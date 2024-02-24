FactoryBot.define do
  factory :rule do
    player_id {1}
    name {"rule_1"}
    mochi {25000}
    kaeshi  {30000}
    uma_one {20}
    uma_two {10}
    uma_three {-10}
    uma_four  {-20}
    score_decimal_point_calc {1}
    is_chip {false}
    play_type {4}
    association :player
  end
end
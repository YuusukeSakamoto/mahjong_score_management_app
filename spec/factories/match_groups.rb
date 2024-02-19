FactoryBot.define do
  factory :match_group do
    association :rule
    association :league
    play_type { 4 }
  end
end
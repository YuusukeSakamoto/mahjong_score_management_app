FactoryBot.define do
  factory :league do
    name { 'test_league' }
    play_type { 4 }
    description { 'test_description' }
    association :player
    association :rule
  end
end
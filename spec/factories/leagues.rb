FactoryBot.define do
  factory :league do
    sequence(:name) { |n| "league#{n}" }
    play_type { 4 }
    description { 'test_description' }
    association :player
    association :rule
  end
end
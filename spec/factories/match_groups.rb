FactoryBot.define do
  factory :match_group do
    association :rule
    association :league
  end
end
FactoryBot.define do
  factory :result do
    association :match
    association :player
  end
end
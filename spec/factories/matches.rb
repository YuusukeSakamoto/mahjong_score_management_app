require 'factory_bot'

FactoryBot.define do
  factory :match do
    rule_id {1}
    match_on {Date.today}
    play_type {4}
    association :player
  end
end

require 'factory_bot'

FactoryBot.define do
  factory :chip_result do
    association :match_group
    association :player
    sequence(:point) { |n| n * 2 }
    sequence(:number) { |n| n }
  end
end
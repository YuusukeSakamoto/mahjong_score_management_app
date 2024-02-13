require 'factory_bot'

FactoryBot.define do
  factory :result do
    association :match
    association :player
    score { 30000 }
    ie { 1 }
    point  { 30 }
    rank { 1 }
  end
end
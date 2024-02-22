require 'factory_bot'

FactoryBot.define do
  factory :share_link do
    association :user
    token { SecureRandom.hex(10) }
  end
end
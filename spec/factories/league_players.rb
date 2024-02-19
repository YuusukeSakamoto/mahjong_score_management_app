FactoryBot.define do
  factory :league_player do
    association :league
    association :player
  end
end
FactoryBot.define do
  factory :match do
    rule_id {1}
    match_on {Date.today}
    association :player
  end
end

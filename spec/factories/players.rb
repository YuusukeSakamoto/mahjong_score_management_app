FactoryBot.define do
  factory :player do
    sequence(:name) { |n| "p#{n}" } # 名前が一意になり、8文字以内になるようにします。
  end
end
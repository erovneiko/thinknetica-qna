FactoryBot.define do
  factory :comment do
    body { "MyText" }

    trait :invalid do
      body { nil }
    end
  end
end

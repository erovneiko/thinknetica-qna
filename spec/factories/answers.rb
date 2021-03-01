FactoryBot.define do
  factory :answer do
    body { 'Answer Body' }

    trait :invalid do
      body { nil }
    end
  end
end

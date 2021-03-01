FactoryBot.define do
  factory :question do
    title { 'Question Title' }
    body { 'Question Body' }

    trait :invalid do
      title { nil }
    end
  end
end

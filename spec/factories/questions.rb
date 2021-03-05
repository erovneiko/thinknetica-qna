FactoryBot.define do
  factory :question do
    title { 'Question Title' }
    body { 'Question Body' }

    trait :invalid do
      title { nil }
    end

    factory :questions_list do
      sequence(:title) { |n| "Question #{n}" }
    end
  end
end

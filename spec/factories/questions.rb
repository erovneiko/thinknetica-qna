FactoryBot.define do
  factory :question do
    title { 'Question title' }
    body { 'Question body' }

    trait :invalid do
      title { nil }
    end

    factory :questions_list do
      sequence(:title) { |n| "Question #{n}" }
    end
  end
end

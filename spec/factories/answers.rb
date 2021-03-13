FactoryBot.define do
  factory :answer do
    body { 'Answer body' }

    trait :invalid do
      body { nil }
    end

    factory :answers_list do
      sequence(:body) { |n| "Answer #{n}" }
    end
  end
end

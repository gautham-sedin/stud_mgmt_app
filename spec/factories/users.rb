FactoryBot.define do
  factory :user do
    sequence(:name)  { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }

    password              { AppConstants::STUDENT_DEFAULT_PASSWORD }
    password_confirmation { AppConstants::STUDENT_DEFAULT_PASSWORD }

    trait :admin do
      role { :admin }
    end

    trait :teacher do
      role { :teacher }
    end

    trait :student do
      role { :student }
    end
  end
end
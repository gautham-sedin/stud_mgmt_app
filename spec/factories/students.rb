FactoryBot.define do
  factory :student do
    association :user, factory: [ :user, :teacher ]

    sequence(:name) do |n|
      "Student #{n}"
    end

    sequence(:email) do |n|
      "student#{n}@example.com"
    end

    age { 20 }

    course { Student::COURSES.sample }

    city { "Chennai" }

    marks { 85 }

    trait :without_marks do
      marks { nil }
    end

    trait :failed_student do
      marks { 20 }
    end

    trait :passed_student do
      marks { 90 }
    end

    trait :with_student_user do
      association :student_user,
                  factory: [ :user, :student ]
    end
  end
end

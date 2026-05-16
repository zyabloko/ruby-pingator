FactoryBot.define do
  factory :ping_result do
    association :ip, strategy: :create
    pinged_at { Time.now }
    success { true }
    rtt { 15.5 }

    trait :failed do
      success { false }
      rtt { nil }
    end

    trait :slow do
      rtt { 500.0 }
    end
  end
end

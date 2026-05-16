FactoryBot.define do
  factory :ip do
    sequence(:ip) { |n| "192.168.1.#{n}" }
    enabled { true }
  end
end

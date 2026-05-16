FactoryBot.define do
  factory :ip_status_interval do
    association :ip, strategy: :create
    enabled_at { Time.now }
    disabled_at { nil }
  end
end

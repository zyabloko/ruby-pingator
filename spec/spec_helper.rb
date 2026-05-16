require 'sequel'
require 'database_cleaner/sequel'
require 'factory_bot'
require 'dotenv'

Dotenv.load('.env.test')

DB = Sequel.connect(ENV.fetch('DATABASE_URL'))

require_relative '../models/ip'
require_relative '../models/ip_status_interval'
require_relative '../models/ping_result'

FactoryBot.define do
  to_create(&:save)
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:suite) do
    DatabaseCleaner[:sequel, db: DB].strategy = :transaction
    DatabaseCleaner[:sequel, db: DB].clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner[:sequel, db: DB].cleaning do
      example.run
    end
  end
end

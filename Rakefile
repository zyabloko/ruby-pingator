require 'rake'

namespace :db do
  desc 'Run migrations'
  task :migrate do
    require 'sequel'
    require 'dotenv'
    Dotenv.load(".env.#{ENV.fetch('RACK_ENV', 'development')}")
    Sequel.extension :migration
    db = Sequel.connect(ENV.fetch('DATABASE_URL'))
    Sequel::Migrator.run(db, 'db/migrations')
    puts 'Migrations complete.'
  end
end

namespace :ping do
  desc 'Ping all enabled IPs and record results'
  task :run do
    require_relative 'config/database'
    require_relative 'jobs/ping_job'
    Jobs::PingJob.run
  end
end

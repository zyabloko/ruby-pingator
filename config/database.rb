require 'sequel'
require 'dotenv'

Dotenv.load(".env.#{ENV.fetch('RACK_ENV', 'development')}")

DB = Sequel.connect(ENV.fetch('DATABASE_URL'))

Sequel.extension :pg_inet_ops

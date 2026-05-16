require_relative 'config/database'
require_relative 'api/ip'

use Rack::Reloader, 0

run API::Ip

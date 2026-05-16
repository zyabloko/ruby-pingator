env :RACK_ENV, ENV.fetch('RACK_ENV', 'development')
set :path, File.expand_path('..', __dir__)

every 1.minute do
  rake 'ping:run'
end

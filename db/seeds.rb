require_relative '../config/database'
require_relative '../models/ip'
require_relative '../models/ip_status_interval'
require_relative '../models/ping_result'

NOW   = Time.now
MIN   = 60
HOUR  = 60 * MIN
DAY   = 24 * HOUR

DB.transaction do
  # Active IP — currently being monitored
  ip1 = Ip.create(ip: '192.168.1.1', enabled: true)
  IpStatusInterval.create(ip_id: ip1.id, enabled_at: NOW - (7 * DAY))
  200.times do |i|
    success = rand < 0.9
    PingResult.create(ip_id: ip1.id, pinged_at: NOW - (7 * DAY) + (i * MIN), success: success,
                      rtt: success ? (rand * 100).round(3) : nil)
  end

  # IP with a monitoring gap (disabled, then re-enabled)
  ip2 = Ip.create(ip: '192.168.1.2', enabled: true)
  IpStatusInterval.create(ip_id: ip2.id, enabled_at: NOW - (14 * DAY), disabled_at: NOW - (10 * DAY))
  IpStatusInterval.create(ip_id: ip2.id, enabled_at: NOW - (5 * DAY))
  150.times do |i|
    success = rand < 0.9
    PingResult.create(ip_id: ip2.id, pinged_at: NOW - (14 * DAY) + (i * MIN), success: success,
                      rtt: success ? (rand * 100).round(3) : nil)
  end

  # Disabled IP — was monitored, now stopped
  ip3 = Ip.create(ip: '10.0.0.1', enabled: false)
  IpStatusInterval.create(ip_id: ip3.id, enabled_at: NOW - (30 * DAY), disabled_at: NOW - (2 * DAY))
  300.times do |i|
    success = rand < 0.9
    PingResult.create(ip_id: ip3.id, pinged_at: NOW - (30 * DAY) + (i * MIN), success: success,
                      rtt: success ? (rand * 100).round(3) : nil)
  end

  # Active IP with no ping results yet
  ip4 = Ip.create(ip: '8.8.8.8', enabled: true)
  IpStatusInterval.create(ip_id: ip4.id, enabled_at: NOW - (60 * MIN))

  # Disabled IP — never monitored
  Ip.create(ip: '1.1.1.1', enabled: false)
end

puts 'Done.'

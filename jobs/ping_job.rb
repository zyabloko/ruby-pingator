require_relative '../models/ip'
require_relative '../models/ping_result'
require_relative '../services/ping_service/check'

module Jobs
  class PingJob
    def self.run
      ips = Ip.where(enabled: true).all
      puts "Pinging #{ips.size} IPs..."

      ips.each do |ip|
        result = PingService::Check.new(ip: ip).call
        puts "  #{ip.ip}: #{result.success ? "ok (#{result.rtt}ms)" : 'unreachable'}"
      rescue StandardError => e
        puts "  #{ip.ip}: error — #{e.message}"
      end

      puts 'Done.'
    end
  end
end

require 'net/ping'

module PingService
  class Check
    TIMEOUT = 5 # seconds

    attr_reader :ip

    def initialize(ip:)
      @ip = ip
    end

    def call
      pinger = Net::Ping::ICMP.new(ip.ip, nil, TIMEOUT)
      started_at = Time.now
      success = pinger.ping?
      rtt = success ? pinger.duration&.*(1000)&.round(3) : nil

      PingResult.create(
        ip_id: ip.id,
        pinged_at: started_at,
        success: success,
        rtt: rtt
      )
    end
  end
end

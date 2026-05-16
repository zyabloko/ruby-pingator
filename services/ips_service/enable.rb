module IpsService
  class Enable
    attr_reader :ip

    def initialize(ip:)
      @ip = ip
    end

    def call
      unless @ip.enabled
        DB.transaction do
          @ip.update(enabled: true)
          IpStatusInterval.create(ip_id: @ip.id, enabled_at: Time.now)
        end
      end

      result
    end

    def result
      {
        id: @ip.id,
        ip: @ip.ip,
        enabled: @ip.enabled
      }
    end
  end
end

module IpsService
  class Disable
    attr_reader :ip

    def initialize(ip:)
      @ip = ip
    end

    def call
      if @ip.enabled
        DB.transaction do
          active_interval = IpStatusInterval.where(ip_id: @ip.id, disabled_at: nil).first
          active_interval&.update(disabled_at: Time.now)

          @ip.update(enabled: false)
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

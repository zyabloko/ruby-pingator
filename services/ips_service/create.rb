require_relative '../../api/errors/validation'

module IpsService
  class Create
    attr_reader :ip_address, :enabled, :ip

    def initialize(ip_address:, enabled: true)
      @ip_address = ip_address
      @enabled = enabled
    end

    def call
      @ip = Ip.new(ip: ip_address, enabled: enabled)

      raise API::Errors::Validation, @ip.errors.full_messages.join(', ') unless @ip.valid?

      DB.transaction do
        @ip.save_changes

        IpStatusInterval.create(ip_id: @ip.id, enabled_at: Time.now) if @ip.enabled
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

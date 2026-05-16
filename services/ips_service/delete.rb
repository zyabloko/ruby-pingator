module IpsService
  class Delete
    attr_reader :ip

    def initialize(ip:)
      @ip = ip
    end

    def call
      @ip.destroy
      { message: 'IP deleted successfully' }
    end
  end
end

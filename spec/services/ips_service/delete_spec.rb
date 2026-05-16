require_relative '../../spec_helper'
require_relative '../../../services/ips_service/delete'

RSpec.describe IpsService::Delete do
  subject(:service) { described_class.new(ip: ip) }

  let(:ip) { create(:ip) }

  describe '#call' do
    it 'destroys the IP' do
      ip
      expect { service.call }.to change { Ip.count }.by(-1)
    end

    it 'destroys associated intervals' do
      create(:ip_status_interval, ip: ip)
      expect { service.call }.to change { IpStatusInterval.count }.by(-1)
    end

    it 'destroys associated ping results' do
      create(:ping_result, ip: ip)
      expect { service.call }.to change { PingResult.count }.by(-1)
    end

    it 'returns a success message' do
      expect(service.call).to eq(message: 'IP deleted successfully')
    end
  end
end

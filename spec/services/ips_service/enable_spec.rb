require_relative '../../spec_helper'
require_relative '../../../services/ips_service/enable'

RSpec.describe IpsService::Enable do
  subject(:service) { described_class.new(ip: ip) }

  describe '#call' do
    context 'when the IP is disabled' do
      let(:ip) { create(:ip, enabled: false) }

      it 'enables the IP' do
        service.call
        expect(ip.reload.enabled).to be true
      end

      it 'creates an IpStatusInterval' do
        expect { service.call }.to change { IpStatusInterval.count }.by(1)
      end

      it 'returns the result hash' do
        expect(service.call).to include(enabled: true)
      end
    end

    context 'when the IP is already enabled' do
      let(:ip) { create(:ip, enabled: true) }

      it 'does not create an IpStatusInterval' do
        expect { service.call }.not_to change { IpStatusInterval.count }
      end

      it 'returns the result hash' do
        expect(service.call).to include(enabled: true)
      end
    end
  end
end

require_relative '../../spec_helper'
require_relative '../../../services/ips_service/disable'

RSpec.describe IpsService::Disable do
  subject(:service) { described_class.new(ip: ip) }

  describe '#call' do
    context 'when the IP is enabled' do
      let(:ip) { create(:ip, enabled: true) }
      let!(:interval) { create(:ip_status_interval, ip: ip, disabled_at: nil) }

      it 'disables the IP' do
        service.call
        expect(ip.reload.enabled).to be false
      end

      it 'closes the active interval' do
        service.call
        expect(interval.reload.disabled_at).not_to be_nil
      end

      it 'returns the result hash' do
        expect(service.call).to include(enabled: false)
      end
    end

    context 'when the IP is already disabled' do
      let(:ip) { create(:ip, enabled: false) }

      it 'does not change the IP' do
        expect { service.call }.not_to(change { ip.reload.enabled })
      end

      it 'returns the result hash' do
        expect(service.call).to include(enabled: false)
      end
    end
  end
end

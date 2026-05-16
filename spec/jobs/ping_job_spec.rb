require_relative '../spec_helper'
require_relative '../../jobs/ping_job'

RSpec.describe Jobs::PingJob do
  describe '.run' do
    let(:enabled_ip)  { create(:ip, enabled: true) }
    let(:disabled_ip) { create(:ip, enabled: false) }

    before do
      enabled_ip
      disabled_ip
      allow(PingService::Check).to receive(:new).and_call_original
    end

    it 'only pings enabled IPs' do
      allow_any_instance_of(PingService::Check).to receive(:call).and_return(create(:ping_result, ip: enabled_ip))

      described_class.run

      expect(PingService::Check).to have_received(:new).with(ip: enabled_ip)
      expect(PingService::Check).not_to have_received(:new).with(ip: disabled_ip)
    end

    it 'creates a PingResult for each enabled IP' do
      allow_any_instance_of(PingService::Check).to receive(:call) { create(:ping_result, ip: enabled_ip) }

      expect { described_class.run }.to change { PingResult.count }.by(1)
    end

    it 'continues processing remaining IPs when one raises an error' do
      create(:ip, enabled: true)
      ip2 = create(:ip, enabled: true)

      call_count = 0
      allow_any_instance_of(PingService::Check).to receive(:call) do
        call_count += 1
        raise 'timeout' if call_count == 1

        create(:ping_result, ip: ip2)
      end

      expect { described_class.run }.not_to raise_error
    end
  end
end

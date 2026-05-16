require_relative '../../spec_helper'
require_relative '../../../services/ips_service/stats'

RSpec.describe IpsService::Stats do
  subject(:service) { described_class.new(ip: ip, time_from: time_from, time_to: time_to) }

  let(:ip) { create(:ip) }
  let(:time_from) { DateTime.now - 1 }
  let(:time_to) { DateTime.now }

  describe '#call' do
    context 'with no active intervals in the period' do
      it 'raises API::Errors::Validation' do
        expect { service.call }.to raise_error(API::Errors::Validation, /No active monitoring/)
      end
    end

    context 'with an active interval but fewer than 2 pings' do
      before do
        create(:ip_status_interval, ip: ip, enabled_at: time_from - 1, disabled_at: nil)
        create(:ping_result, ip: ip, pinged_at: time_from + 0.5, success: true, rtt: 10.0)
      end

      it 'raises API::Errors::Validation' do
        expect { service.call }.to raise_error(API::Errors::Validation, /Not enough measurements/)
      end
    end

    context 'with sufficient data' do
      before do
        create(:ip_status_interval, ip: ip, enabled_at: time_from - 1, disabled_at: nil)
        create(:ping_result, ip: ip, pinged_at: time_from + 0.1, success: true, rtt: 10.0)
        create(:ping_result, ip: ip, pinged_at: time_from + 0.2, success: true, rtt: 20.0)
        create(:ping_result, ip: ip, pinged_at: time_from + 0.3, success: false, rtt: nil)
      end

      it 'returns stats with the expected keys' do
        result = service.call
        expect(result.keys).to contain_exactly(
          :avg_rtt, :min_rtt, :max_rtt, :median_rtt, :stddev_rtt, :packet_loss_percent
        )
      end

      it 'calculates packet loss correctly' do
        result = service.call
        expect(result[:packet_loss_percent]).to eq(33.33)
      end

      it 'calculates min and max rtt' do
        result = service.call
        expect(result[:min_rtt]).to eq(10.0)
        expect(result[:max_rtt]).to eq(20.0)
      end
    end
  end
end

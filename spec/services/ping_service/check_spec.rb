require_relative '../../spec_helper'
require_relative '../../../services/ping_service/check'

RSpec.describe PingService::Check do
  subject(:service) { described_class.new(ip: ip) }

  let(:ip) { create(:ip, ip: '127.0.0.1') }
  let(:pinger) { instance_double(Net::Ping::ICMP) }

  before do
    allow(Net::Ping::ICMP).to receive(:new).and_return(pinger)
  end

  describe '#call' do
    context 'when the ping succeeds' do
      before do
        allow(pinger).to receive(:ping?).and_return(true)
        allow(pinger).to receive(:duration).and_return(0.015)
      end

      it 'creates a successful PingResult' do
        expect { service.call }.to change { PingResult.count }.by(1)
      end

      it 'records success and rtt' do
        result = service.call
        expect(result.success).to be true
        expect(result.rtt).to eq(15.0)
      end
    end

    context 'when the ping fails' do
      before do
        allow(pinger).to receive(:ping?).and_return(false)
        allow(pinger).to receive(:duration).and_return(nil)
      end

      it 'creates a failed PingResult' do
        expect { service.call }.to change { PingResult.count }.by(1)
      end

      it 'records failure with nil rtt' do
        result = service.call
        expect(result.success).to be false
        expect(result.rtt).to be_nil
      end
    end
  end
end

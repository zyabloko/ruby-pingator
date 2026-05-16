require_relative '../../spec_helper'
require_relative '../../../services/ips_service/create'

RSpec.describe IpsService::Create do
  subject(:service) { described_class.new(ip_address: ip_address, enabled: enabled) }

  let(:ip_address) { '10.0.0.1' }
  let(:enabled) { true }

  describe '#call' do
    context 'with a valid enabled IP' do
      it 'creates an Ip record' do
        expect { service.call }.to change { Ip.count }.by(1)
      end

      it 'creates an IpStatusInterval' do
        expect { service.call }.to change { IpStatusInterval.count }.by(1)
      end

      it 'returns the result hash' do
        result = service.call
        expect(result).to include(ip: ip_address, enabled: true)
        expect(result[:id]).not_to be_nil
      end
    end

    context 'with enabled: false' do
      let(:enabled) { false }

      it 'creates an Ip record' do
        expect { service.call }.to change { Ip.count }.by(1)
      end

      it 'does not create an IpStatusInterval' do
        expect { service.call }.not_to change { IpStatusInterval.count }
      end
    end

    context 'with an invalid IP address' do
      let(:ip_address) { 'not-an-ip' }

      it 'raises API::Errors::Validation' do
        expect { service.call }.to raise_error(API::Errors::Validation)
      end

      it 'does not create an Ip record' do
        expect { service.call rescue nil }.not_to change { Ip.count }
      end
    end

    context 'with a duplicate IP address' do
      before { create(:ip, ip: ip_address) }

      it 'raises API::Errors::Validation' do
        expect { service.call }.to raise_error(API::Errors::Validation)
      end
    end
  end
end

require_relative '../spec_helper'

RSpec.describe Ip do
  describe 'validations' do
    it 'is valid with a valid IPv4 address' do
      expect(build(:ip, ip: '192.168.1.1').valid?).to be true
    end

    it 'is valid with a valid IPv6 address' do
      expect(build(:ip, ip: '2001:db8::1').valid?).to be true
    end

    it 'requires ip to be present' do
      expect(build(:ip, ip: nil).valid?).to be false
    end

    it 'requires ip to be unique' do
      create(:ip, ip: '192.168.1.1')
      expect(build(:ip, ip: '192.168.1.1').valid?).to be false
    end

    it 'rejects an invalid IP address' do
      expect(build(:ip, ip: 'not-an-ip').valid?).to be false
    end

    it 'rejects an IP with out-of-range octets' do
      expect(build(:ip, ip: '999.999.999.999').valid?).to be false
    end
  end

  describe 'associations' do
    let(:ip) { create(:ip) }

    it 'has many ip_status_intervals' do
      interval = create(:ip_status_interval, ip: ip)
      expect(ip.ip_status_intervals).to include(interval)
    end

    it 'has many ping_results' do
      ping = create(:ping_result, ip: ip)
      expect(ip.ping_results).to include(ping)
    end

    it 'destroys associated ip_status_intervals on destroy' do
      create(:ip_status_interval, ip: ip)
      expect { ip.destroy }.to change { IpStatusInterval.count }.by(-1)
    end

    it 'destroys associated ping_results on destroy' do
      create(:ping_result, ip: ip)
      expect { ip.destroy }.to change { PingResult.count }.by(-1)
    end
  end

  describe 'default values' do
    it 'sets enabled to true by default' do
      expect(create(:ip).enabled).to be true
    end
  end

  describe 'timestamps' do
    it 'sets created_at and updated_at on creation' do
      ip = create(:ip)
      expect(ip.created_at).not_to be_nil
      expect(ip.updated_at).not_to be_nil
    end
  end
end

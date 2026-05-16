require_relative '../spec_helper'

RSpec.describe PingResult do
  describe 'validations' do
    it 'is valid with valid attributes' do
      ping = build(:ping_result)
      expect(ping.valid?).to be true
    end

    it 'requires ip_id to be present' do
      ping = build(:ping_result, ip: nil)
      expect(ping.valid?).to be false
    end

    it 'requires pinged_at to be present' do
      ping = build(:ping_result, pinged_at: nil)
      expect(ping.valid?).to be false
    end
  end

  describe 'associations' do
    it 'belongs to ip' do
      ip = create(:ip)
      ping = create(:ping_result, ip: ip)
      expect(ping.ip).to eq(ip)
    end
  end

  describe 'rtt field' do
    it 'can store rtt for successful pings' do
      ping = create(:ping_result, rtt: 25.123)
      expect(ping.rtt).to eq(BigDecimal('25.123'))
    end

    it 'can be null for failed pings (packet loss)' do
      ping = create(:ping_result, :failed)
      expect(ping.rtt).to be_nil
    end
  end

  describe 'success field' do
    it 'defaults to false' do
      ping = create(:ping_result, success: false)
      expect(ping.success).to be false
    end
  end
end

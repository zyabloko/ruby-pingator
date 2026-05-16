require_relative '../spec_helper'

RSpec.describe IpStatusInterval do
  describe 'validations' do
    it 'is valid with valid attributes' do
      interval = build(:ip_status_interval)
      expect(interval.valid?).to be true
    end

    it 'requires ip_id to be present' do
      interval = build(:ip_status_interval, ip: nil)
      expect(interval.valid?).to be false
    end

    it 'requires enabled_at to be present' do
      interval = build(:ip_status_interval, enabled_at: nil)
      expect(interval.valid?).to be false
    end
  end

  describe 'associations' do
    it 'belongs to ip' do
      ip = create(:ip)
      interval = create(:ip_status_interval, ip: ip)
      expect(interval.ip).to eq(ip)
    end
  end

  describe 'disabled_at' do
    it 'can be null for active monitoring' do
      interval = create(:ip_status_interval, disabled_at: nil)
      expect(interval.disabled_at).to be_nil
    end

    it 'can store when monitoring was disabled' do
      now = Time.now
      interval = create(:ip_status_interval, enabled_at: now - 3600, disabled_at: now)
      expect(interval.disabled_at).not_to be_nil
    end
  end
end

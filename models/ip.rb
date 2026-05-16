require 'sequel'
require 'ipaddr'

class Ip < Sequel::Model
  one_to_many :ip_status_intervals
  one_to_many :ping_results

  plugin :timestamps, update_on_create: true
  plugin :validation_helpers
  plugin :association_dependencies,
         ip_status_intervals: :destroy,
         ping_results: :destroy

  def validate
    super
    validates_presence :ip
    errors.add(:ip, 'is not a valid IPv4 or IPv6 address') if ip && !valid_ip?(ip)

    validates_unique :ip
  end

  private

  def valid_ip?(address)
    addr = IPAddr.new(address)
    addr.ipv4? || addr.ipv6?
  rescue IPAddr::InvalidAddressError
    false
  end
end

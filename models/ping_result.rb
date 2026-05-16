require 'sequel'

class PingResult < Sequel::Model
  many_to_one :ip

  plugin :timestamps, update_on_create: true
  plugin :validation_helpers

  def validate
    super
    validates_presence :ip_id
    validates_presence :pinged_at
  end
end

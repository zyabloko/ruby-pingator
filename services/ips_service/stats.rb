require_relative '../../api/errors/validation'

module IpsService
  class Stats
    attr_reader :ip, :time_from, :time_to

    def initialize(ip:, time_from:, time_to:)
      @ip = ip
      @time_from = time_from
      @time_to = time_to
    end

    def call
      active_intervals_exist = IpStatusInterval.where(ip_id: @ip.id)
                                               .where(Sequel.lit('enabled_at <= ?', time_to))
                                               .where(Sequel.lit('disabled_at IS NULL OR disabled_at >= ?', time_from))
                                               .any?

      raise API::Errors::Validation, 'No active monitoring during the requested period' unless active_intervals_exist

      ping_results = PingResult.where(ip_id: @ip.id)
                               .where(success: true)
                               .where(Sequel.lit('pinged_at >= ?', time_from))
                               .where(Sequel.lit('pinged_at <= ?', time_to))

      total_pings = PingResult.where(ip_id: @ip.id)
                              .where(Sequel.lit('pinged_at >= ?', time_from))
                              .where(Sequel.lit('pinged_at <= ?', time_to))
                              .count

      successful_pings = ping_results.count

      raise API::Errors::Validation, 'Not enough measurements during the requested period' if total_pings < 2

      stats = ping_results.select(
        Sequel.function(:avg, :rtt).as(:avg_rtt),
        Sequel.function(:min, :rtt).as(:min_rtt),
        Sequel.function(:max, :rtt).as(:max_rtt),
        Sequel.function(:percentile_cont, 0.5).within_group(:rtt).as(:median_rtt),
        Sequel.function(:stddev, :rtt).as(:stddev_rtt)
      ).first

      packet_loss = ((total_pings - successful_pings).to_f / total_pings * 100).round(2)

      {
        avg_rtt: stats[:avg_rtt]&.to_f&.round(3),
        min_rtt: stats[:min_rtt]&.to_f&.round(3),
        max_rtt: stats[:max_rtt]&.to_f&.round(3),
        median_rtt: stats[:median_rtt]&.to_f&.round(3),
        stddev_rtt: stats[:stddev_rtt]&.to_f&.round(3),
        packet_loss_percent: packet_loss
      }
    end
  end
end

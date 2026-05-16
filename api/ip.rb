require 'grape'
require 'grape_logging'
require_relative '../models/ip'
require_relative '../models/ip_status_interval'
require_relative '../models/ping_result'
require_relative '../services/ips_service/create'
require_relative '../services/ips_service/enable'
require_relative '../services/ips_service/disable'
require_relative '../services/ips_service/stats'
require_relative '../services/ips_service/delete'
require_relative 'errors/base'
require_relative 'errors/not_found'
require_relative 'errors/validation'

module API
  class Ip < Grape::API
    format :json
    prefix :api

    rescue_from API::Errors::Base do |e|
      error!({ error: e.message }, e.status)
    end

    rescue_from :all do |_e|
      error!({ error: 'Internal server error' }, 500)
    end

    helpers do
      def find_ip!
        ip = ::Ip[params[:id]]
        raise API::Errors::NotFound, 'IP not found' unless ip

        ip
      end
    end

    resource :ips do
      desc 'Register a new IP address'
      params do
        requires :ip, type: String, desc: 'IPv4/IPv6 address'
        optional :enabled, type: Boolean, desc: 'Enable monitoring', default: true
      end
      post do
        service = IpsService::Create.new(ip_address: params[:ip], enabled: params[:enabled])
        service.call
      end

      route_param :id do
        desc 'Enable monitoring and stats collection for an IP'
        post :enable do
          ip = find_ip!
          service = IpsService::Enable.new(ip: ip)
          service.call
        end

        desc 'Disable monitoring and stats collection for an IP'
        post :disable do
          ip = find_ip!
          service = IpsService::Disable.new(ip: ip)
          service.call
        end

        desc 'Fetch statistics for an IP'
        params do
          requires :time_from, type: DateTime, desc: 'Start time'
          requires :time_to, type: DateTime, desc: 'End time'
        end
        get :stats do
          ip = find_ip!
          service = IpsService::Stats.new(
            ip: ip,
            time_from: params[:time_from],
            time_to: params[:time_to]
          )
          service.call
        end

        desc 'Disable monitoring and remove the IP address'
        delete do
          ip = find_ip!
          service = IpsService::Delete.new(ip: ip)
          service.call
        end
      end
    end
  end
end

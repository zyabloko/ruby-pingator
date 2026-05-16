require_relative '../spec_helper'
require 'rack/test'
require_relative '../../api/ip'

RSpec.describe API::Ip do
  include Rack::Test::Methods

  def app
    API::Ip
  end

  def json_body
    JSON.parse(last_response.body, symbolize_names: true)
  end

  describe 'POST /api/ips' do
    context 'with valid params' do
      it 'returns 201 and creates an IP' do
        post '/api/ips', { ip: '10.0.0.1' }.to_json, 'CONTENT_TYPE' => 'application/json'
        expect(last_response.status).to eq(201)
        expect(json_body[:ip]).to eq('10.0.0.1')
        expect(json_body[:enabled]).to be true
      end
    end

    context 'with an invalid IP' do
      it 'returns 422' do
        post '/api/ips', { ip: 'bad' }.to_json, 'CONTENT_TYPE' => 'application/json'
        expect(last_response.status).to eq(422)
        expect(json_body[:error]).to be_present
      end
    end
  end

  describe 'POST /api/ips/:id/enable' do
    let(:ip) { create(:ip, enabled: false) }

    it 'enables the IP and returns 201' do
      post "/api/ips/#{ip.id}/enable"
      expect(last_response.status).to eq(201)
      expect(json_body[:enabled]).to be true
    end

    it 'returns 404 for unknown id' do
      post '/api/ips/0/enable'
      expect(last_response.status).to eq(404)
    end
  end

  describe 'POST /api/ips/:id/disable' do
    let(:ip) { create(:ip, enabled: true) }

    it 'disables the IP and returns 201' do
      post "/api/ips/#{ip.id}/disable"
      expect(last_response.status).to eq(201)
      expect(json_body[:enabled]).to be false
    end

    it 'returns 404 for unknown id' do
      post '/api/ips/0/disable'
      expect(last_response.status).to eq(404)
    end
  end

  describe 'GET /api/ips/:id/stats' do
    let(:ip) { create(:ip) }
    let(:time_from) { (DateTime.now - 1).iso8601 }
    let(:time_to) { DateTime.now.iso8601 }

    context 'with no monitoring data' do
      it 'returns 422' do
        get "/api/ips/#{ip.id}/stats", time_from: time_from, time_to: time_to
        expect(last_response.status).to eq(422)
      end
    end

    it 'returns 404 for unknown id' do
      get '/api/ips/0/stats', time_from: time_from, time_to: time_to
      expect(last_response.status).to eq(404)
    end
  end

  describe 'DELETE /api/ips/:id' do
    let!(:ip) { create(:ip) }

    it 'deletes the IP and returns 200' do
      delete "/api/ips/#{ip.id}"
      expect(last_response.status).to eq(200)
      expect(json_body[:message]).to eq('IP deleted successfully')
    end

    it 'returns 404 for unknown id' do
      delete '/api/ips/0'
      expect(last_response.status).to eq(404)
    end
  end
end

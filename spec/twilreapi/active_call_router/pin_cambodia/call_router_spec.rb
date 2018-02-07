require 'spec_helper'

describe Twilreapi::ActiveCallRouter::PinCambodia::CallRouter do
  include EnvHelpers

  ASSERTED_SERVICES = {
    :ews => {
      :source_number => "8551294",
      :caller_id => "1294"
    },
    :mhealth => {
      :source_number => "8551296",
      :caller_id => "1296"
    }
  }

  ASSERTED_OPERATORS = {
    :smart => {
      :sample_number => "+85510344566",
      :asserted_address => "010344566@27.109.112.80"
    },
    :cellcard => {
      :sample_number => "+85512345677",
      :asserted_address => "012345677@103.193.204.17"
    },
    :metfone => {
      :sample_number => "+855882345678",
      :asserted_address => "0882345678@175.100.32.29",
      :asserted_caller_id_exceptions => {
        :services => {
          :mhealth => "095975802"
        }
      },
      :asserted_address_exceptions => {
        :services => {
          :mhealth => "0882345678@103.193.204.17"
        }
      }
    }
  }

  class DummyPhoneCall
    attr_accessor :from, :to, :variables

    def initialize(attributes = {})
      self.from = attributes[:from]
      self.to = attributes[:to]
      self.variables = attributes[:variables]
    end

    def variables
      @variables ||= {}
    end
  end

  let(:source) { "8559999" }
  let(:destination) { "+85518345678" }
  let(:asserted_destination) { destination.sub(/^\+/, "") }
  let(:asserted_disable_originate) { nil }
  let(:asserted_address) { asserted_destination }

  let(:phone_call_attributes) {
    {
      :from => source,
      :to => destination
    }
  }

  let(:phone_call_instance) { DummyPhoneCall.new(phone_call_attributes) }
  let(:options) { {:phone_call => phone_call_instance} }

  subject { described_class.new(options) }

  before do
    setup_scenario
  end

  def setup_scenario
    stub_env(env)
  end

  describe "#normalized_from" do
    let(:trunk_prefix) { "0" }
    let(:trunk_prefix_replacement) { "855" }
    let(:result) { subject.normalize_from }

    def env
      {
        :twilreapi_active_call_router_pin_cambodia_trunk_prefix => trunk_prefix,
        :twilreapi_active_call_router_pin_cambodia_trunk_prefix_replacement => trunk_prefix_replacement
      }
    end

    def assert_normalized_from!
      expect(result).to eq(asserted_normalized_from)
    end

    context "source: '+0972345678'" do
      let(:source) { "+0972345678" }

      context "trunk_prefix_replacement: '855'" do
        let(:trunk_prefix_replacement) { "855" }
        let(:asserted_normalized_from) { "+855972345678" }
        it { assert_normalized_from! }
      end

      context "trunk_prefix_replacement: '856'" do
        let(:trunk_prefix_replacement) { "856" }
        let(:asserted_normalized_from) { "+856972345678" }
        it { assert_normalized_from! }
      end

      context "trunk_prefix_replacement: nil" do
        let(:trunk_prefix_replacement) { nil }
        let(:asserted_normalized_from) { source }
        it { assert_normalized_from! }
      end

      context "trunk_prefix: '1'" do
        let(:trunk_prefix) { "1" }
        let(:asserted_normalized_from) { source }
        it { assert_normalized_from! }
      end
    end

    context "source: '+855972345678'" do
      let(:source) { "+855972345678" }
      let(:asserted_normalized_from) { source }
      it { assert_normalized_from! }
    end

    context "source: '855972345678'" do
      let(:source) { "855972345678" }
      let(:asserted_normalized_from) { source }
      it { assert_normalized_from! }
    end

    context "source: '10972345678'" do
      let(:source) { "10972345678" }
      let(:asserted_normalized_from) { source }
      it { assert_normalized_from! }
    end
  end

  describe "#routing_instructions" do
    let(:routing_instructions) { subject.routing_instructions }
    let(:asserted_dial_string_path) { "external/#{asserted_address}" }

    def generate_env_from_services
      service_env = {}
      ASSERTED_SERVICES.each do |asserted_service_name, params|
        service_env[:"twilreapi_active_call_router_pin_cambodia_#{asserted_service_name}_source_number"] = params[:source_number]
        service_env[:"twilreapi_active_call_router_pin_cambodia_#{asserted_service_name}_caller_id"] = params[:caller_id]
      end
      service_env
    end

    def env
      generate_env_from_services
    end

    def assert_routing_instructions!
      expect(routing_instructions["disable_originate"]).to eq(asserted_disable_originate)
      expect(routing_instructions["source"]).to eq(asserted_caller_id)
      expect(routing_instructions["destination"]).to eq(asserted_destination)

      if !asserted_disable_originate
        expect(routing_instructions["dial_string_path"]).to eq(asserted_dial_string_path)
      end
    end

    def asserted_exceptions(operator_params, exception_type, service_name)
      ((operator_params[exception_type] || {})[:services] || {})[service_name]
    end

    ASSERTED_OPERATORS.each do |asserted_operator_name, operator_params|
      context "destination: #{asserted_operator_name}" do
        let(:destination) { operator_params[:sample_number] }

        ASSERTED_SERVICES.each do |asserted_service_name, service_params|
          context "source: #{asserted_service_name}" do
            let(:source) { service_params[:source_number] }

            let(:asserted_caller_id) {
              asserted_exceptions(
                operator_params,
                :asserted_caller_id_exceptions,
                asserted_service_name
              ) || service_params[:caller_id]
            }

            let(:asserted_address) {
              asserted_exceptions(
                operator_params,
                :asserted_address_exceptions,
                asserted_service_name
              ) || operator_params[:asserted_address]
            }

            it { assert_routing_instructions! }
          end
        end
      end
    end

    context "source unknown" do
      let(:destination) { ASSERTED_OPERATORS[:smart][:sample_number] }
      let(:asserted_address) { ASSERTED_OPERATORS[:smart][:asserted_address] }
      let(:asserted_caller_id) { source }

      it { assert_routing_instructions! }
    end

    context "destination unknown" do
      let(:asserted_caller_id) { source }
      let(:asserted_gateway) { nil }
      let(:asserted_disable_originate) { "1" }

      it { assert_routing_instructions! }
    end
  end
end

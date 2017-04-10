require 'spec_helper'

describe Twilreapi::ActiveCallRouter::PinCambodia::CallRouter do
  include EnvHelpers

  class DummyPhoneCall
    attr_accessor :from, :to

    def initialize(attributes = {})
      self.from = attributes[:from]
      self.to = attributes[:to]
    end
  end

  let(:source) { "8559999" }
  let(:destination) { "+85518345678" }
  let(:asserted_destination) { destination.sub(/^\+/, "") }
  let(:asserted_disable_originate) { nil }
  let(:asserted_address) { asserted_destination }

  let(:mhealth_source_number) { "8551777" }
  let(:mhealth_caller_id) { "1234" }
  let(:ews_source_number) { "8551778" }
  let(:ews_caller_id) { "4321" }

  let(:smart_number)    { "+85510344566"  }
  let(:cellcard_number) { "+85512345677"  }
  let(:metfone_number)  { "+855882345678" }

  let(:phone_call_attributes) { { :from => source, :to => destination } }
  let(:phone_call_instance) { DummyPhoneCall.new(phone_call_attributes) }
  let(:options) { {:phone_call => phone_call_instance} }

  subject { described_class.new(options) }

  before do
    setup_scenario
  end

  def setup_scenario
    stub_env(
      :"twilreapi_active_call_router_pin_cambodia_mhealth_source_number" => mhealth_source_number,
      :"twilreapi_active_call_router_pin_cambodia_ews_source_number" => ews_source_number,
      :"twilreapi_active_call_router_pin_cambodia_mhealth_caller_id" => mhealth_caller_id,
      :"twilreapi_active_call_router_pin_cambodia_ews_caller_id" => ews_caller_id
    )
  end

  describe "#routing_instructions" do
    let(:routing_instructions) { subject.routing_instructions }
    let(:asserted_dial_string_path) { "gateway/#{asserted_gateway}/#{asserted_address}" }

    def assert_routing_instructions!
      expect(routing_instructions["disable_originate"]).to eq(asserted_disable_originate)
      expect(routing_instructions["source"]).to eq(asserted_caller_id)
      expect(routing_instructions["destination"]).to eq(asserted_destination)

      if !asserted_disable_originate
        expect(routing_instructions["dial_string_path"]).to eq(asserted_dial_string_path)
      end
    end

    context "source: mhealth" do
      let(:source) { mhealth_source_number }
      let(:asserted_caller_id) { mhealth_caller_id }

      context "Smart" do
        let(:destination) { smart_number }
        let(:asserted_host) { "27.109.112.80" }
        let(:asserted_address) { "#{asserted_destination}@#{asserted_host}" }
        let(:asserted_dial_string_path) { "external/#{asserted_address}" }

        it { assert_routing_instructions! }
      end

      context "Cellcard" do
        let(:asserted_gateway) { "pin_kh_08" }
        let(:destination) { cellcard_number }
        let(:asserted_address) { "012345677" }
        it { assert_routing_instructions! }
      end

      context "Metfone" do
        let(:asserted_gateway) { "pin_kh_08" }
        let(:destination) { metfone_number }
        let(:asserted_address) { "0882345678" }
        it { assert_routing_instructions! }
      end
    end

    context "source: ews" do
      let(:source) { ews_source_number }
      let(:asserted_caller_id) { ews_caller_id }

      context "Smart" do
        let(:destination) { smart_number }
        let(:asserted_gateway) { "pin_kh_07" }
        let(:asserted_address) { "010344566" }
        it { assert_routing_instructions! }
      end

      context "Cellcard" do
        let(:destination) { cellcard_number }
        let(:asserted_gateway) { "pin_kh_05" }
        let(:asserted_address) { "012345677" }
        it { assert_routing_instructions! }
      end

      context "Metfone" do
        let(:destination) { metfone_number }
        let(:asserted_gateway) { "pin_kh_06" }
        let(:asserted_address) { "0882345678" }
        it { assert_routing_instructions! }
      end
    end

    context "source: unknown" do
      let(:asserted_caller_id) { source }

      context "Smart" do
        let(:destination) { smart_number }
        let(:asserted_gateway) { "pin_kh_08" }
        let(:asserted_address) { "010344566" }
        it { assert_routing_instructions! }
      end

      context "Cellcard" do
        let(:destination) { cellcard_number }
        let(:asserted_gateway) { "pin_kh_08" }
        let(:asserted_address) { "012345677" }
        it { assert_routing_instructions! }
      end

      context "Metfone" do
        let(:destination) { metfone_number }
        let(:asserted_gateway) { "pin_kh_08" }
        let(:asserted_address) { "0882345678" }
        it { assert_routing_instructions! }
      end
    end

    context "destination unknown" do
      let(:asserted_caller_id) { source }
      let(:asserted_gateway) { nil }
      let(:asserted_disable_originate) { "1" }
      it { assert_routing_instructions! }
    end
  end
end


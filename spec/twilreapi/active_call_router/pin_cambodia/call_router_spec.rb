require 'spec_helper'

describe Twilreapi::ActiveCallRouter::PinCambodia::CallRouter do
  include EnvHelpers

  let(:source) { "8551777" }
  let(:destination) { "85512345678" }

  let(:mhealth_source_number) { "8551777" }
  let(:mhealth_caller_id) { "1234" }
  let(:ews_source_number) { "8551778" }
  let(:ews_caller_id) { "4321" }

  let(:smart_number)    { "85510344566"  }
  let(:cellcard_number) { "85512345677"  }
  let(:metfone_number)  { "855882345678" }

  subject { described_class.new(source, destination) }

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

    def assert_routing_instructions!
      expect(routing_instructions["source"]).to eq(source)
      expect(routing_instructions["destination"]).to eq(destination)
      expect(routing_instructions["caller_id"]).to eq(asserted_caller_id)
      expect(routing_instructions["gateway"]).to eq(asserted_gateway)
    end

    context "mhealth" do
      let(:source) { mhealth_source_number }
      let(:asserted_gateway) { "pin_kh_04" }
      let(:asserted_caller_id) { mhealth_caller_id }

      context "Smart" do
        let(:destination) { smart_number }
        it { assert_routing_instructions! }
      end

      context "Cellcard" do
        let(:destination) { cellcard_number }
        it { assert_routing_instructions! }
      end

      context "Metfone" do
        let(:destination) { metfone_number }
        it { assert_routing_instructions! }
      end
    end

    context "ews" do
      let(:source) { ews_source_number }
      let(:asserted_caller_id) { ews_caller_id }

      context "Smart" do
        let(:destination) { smart_number }
        let(:asserted_gateway) { "pin_kh_07" }
        it { assert_routing_instructions! }
      end

      context "Cellcard" do
        let(:destination) { cellcard_number }
        let(:asserted_gateway) { "pin_kh_05" }
        it { assert_routing_instructions! }
      end

      context "Metfone" do
        let(:destination) { metfone_number }
        let(:asserted_gateway) { "pin_kh_06" }
        it { assert_routing_instructions! }
      end
    end
  end
end


require 'spec_helper'

describe Twilreapi::ActiveCallRouter::PinCambodia::CallRouter do
  let(:source) { "8551777" }
  let(:destination) { "85512345678" }

  subject { described_class.new(source, destination) }

  describe "#routing_instructions" do
    it { expect(subject.routing_instructions).to eq({}) }
  end
end


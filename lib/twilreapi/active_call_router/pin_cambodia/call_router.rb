require "twilreapi/active_call_router/base"
require_relative "torasup"

class Twilreapi::ActiveCallRouter::PinCambodia::CallRouter < Twilreapi::ActiveCallRouter::Base
  attr_accessor :gateway, :caller_id

  def routing_instructions
    @routing_instructions ||= super.merge(generate_routing_instructions)
  end

  private

  def source
    options[:source]
  end

  def destination
    options[:destination]
  end

  def generate_routing_instructions
    set_routing_variables
    gateway_configuration = gateway || fallback_gateway || {}
    gateway_name = gateway_configuration["name"]
    address = normalized_destination
    address = Phony.format(address, :format => :national, :spaces => "") if gateway_configuration["prefix"] == false

    routing_instructions = {
      "source" => caller_id || source,
      "destination" => normalized_destination,
      "address" => address
    }

    routing_instructions.merge!("gateway" => gateway_name) if gateway_name
    routing_instructions.merge!("disable_originate" => "1") if !gateway_name
    routing_instructions
  end

  def set_routing_variables
    case source
    when mhealth_source_number
      self.gateway = mhealth_gateway
      self.caller_id = mhealth_caller_id
    when ews_source_number
      self.gateway = ews_gateway
      self.caller_id = ews_caller_id
    end
  end

  def fallback_gateway
    gateways["fallback"] || other_gateways.first
  end

  def mhealth_gateway
    gateways["mhealth_default"]
  end

  def ews_gateway
    gateways["ews_default"]
  end

  def other_gateways
    gateways["others"] || []
  end

  def gateways
    operator.gateways || {}
  end

  def operator
    destination_torasup_number.operator
  end

  def destination_torasup_number
    @destination_torasup_number ||= Torasup::PhoneNumber.new(normalized_destination)
  end

  def normalized_destination
    @normalized_destination ||= Phony.normalize(destination)
  end

  def self.configuration(key)
    ENV["TWILREAPI_ACTIVE_CALL_ROUTER_PIN_CAMBODIA_#{key.to_s.upcase}"]
  end

  def mhealth_source_number
    self.class.configuration("mhealth_source_number")
  end

  def mhealth_caller_id
    self.class.configuration("mhealth_caller_id")
  end

  def ews_source_number
    self.class.configuration("ews_source_number")
  end

  def ews_caller_id
    self.class.configuration("ews_caller_id")
  end
end

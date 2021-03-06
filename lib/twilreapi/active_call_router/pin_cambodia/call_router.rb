# frozen_string_literal: true

require 'twilreapi/active_call_router/base'
require_relative 'torasup'

class Twilreapi::ActiveCallRouter::PinCambodia::CallRouter < Twilreapi::ActiveCallRouter::Base
  DEFAULT_TRUNK_PREFIX = '0'
  attr_accessor :gateway, :caller_id

  def normalize_from
    if source && trunk_prefix_replacement
      source.sub(/\A((\+)?#{trunk_prefix})/, "\\2#{trunk_prefix_replacement}")
    else
      source
    end
  end

  def routing_instructions
    @routing_instructions ||= generate_routing_instructions
  end

  private

  def phone_call
    options[:phone_call]
  end

  def from_host
    phone_call.variables['sip_from_host']
  end

  def source
    phone_call.from
  end

  def destination
    phone_call.to
  end

  def generate_routing_instructions
    set_routing_variables
    gateway_configuration = gateway || {}
    gateway_name = gateway_configuration['name']
    gateway_host = gateway_configuration['host']
    gateway_caller_id = gateway_configuration['caller_id']
    address = normalized_destination

    if gateway_configuration['prefix'] == false || default_to_national_dial_string_format?
      address = Phony.format(
        address,
        format: :national,
        spaces: ''
      )
    end

    address = address.sub(/^0/, '') if gateway_configuration['trunk'] == false

    if gateway_name
      dial_string_path = "gateway/#{gateway_name}/#{address}"
    elsif gateway_host
      dial_string_path = "external/#{address}@#{gateway_host}"
    end

    routing_instructions = {
      'source' => gateway_caller_id || caller_id || source,
      'destination' => normalized_destination
    }

    if dial_string_path
      routing_instructions['dial_string_path'] = dial_string_path
    else
      routing_instructions['disable_originate'] = '1'
    end

    routing_instructions
  end

  def set_routing_variables
    case source
    when mhealth_source_number
      self.caller_id = mhealth_caller_id
      self.gateway = mhealth_gateway
    when ews_source_number
      self.caller_id = ews_caller_id
    end
    self.gateway ||= default_gateway
  end

  def default_gateway
    gateways['default']
  end

  def mhealth_gateway
    gateways['mhealth']
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
    options[:mhealth_source_number] || self.class.configuration('mhealth_source_number')
  end

  def mhealth_caller_id
    options[:mhealth_caller_id] || self.class.configuration('mhealth_caller_id')
  end

  def ews_source_number
    options[:ews_source_number] || self.class.configuration('ews_source_number')
  end

  def ews_caller_id
    options[:ews_caller_id] || self.class.configuration('ews_caller_id')
  end

  def default_dial_string_format
    options[:default_dial_string_format] || self.class.configuration('default_dial_string_format')
  end

  def default_to_national_dial_string_format?
    default_dial_string_format == 'NATIONAL'
  end

  def trunk_prefix
    options[:trunk_prefix] || self.class.configuration('trunk_prefix') || DEFAULT_TRUNK_PREFIX
  end

  def trunk_prefix_replacement
    options[:trunk_prefix_replacement] || self.class.configuration('trunk_prefix_replacement')
  end
end

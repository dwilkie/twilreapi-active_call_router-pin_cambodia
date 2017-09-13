# Twilreapi::ActiveCallRouter::PinCambodia

[![Build Status](https://travis-ci.org/somleng/twilreapi-active_call_router-pin_cambodia.svg?branch=master)](https://travis-ci.org/somleng/twilreapi-active_call_router-pin_cambodia)

This gem contains call routing logic for People In Need Cambodia for [Twilreapi.](https://github.com/somleng/twilreapi)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'twilreapi-active_call_router-pin_cambodia', :github => "somleng/twilreapi-active_call_router-pin_cambodia"
```

And then execute:

    $ bundle

## Configuration

To configure [Twilreapi](https://github.com/somleng/twilreapi) to use `Twilreapi::ActiveBiller::PinCambodia::CallRouter`, set the environment variable `ACTIVE_CALL_ROUTER_CLASS_NAME=Twilreapi::ActiveCallRouter::PinCambodia::CallRouter`

The following environment variables can be set to determine the call routing logic:

* `TWILREAPI_ACTIVE_CALL_ROUTER_PIN_CAMBODIA_DEFAULT_DIAL_STRING_FORMAT`
  * Defaults to international format. Set to `NATIONAL` to default to national dial string format
* `TWILREAPI_ACTIVE_CALL_ROUTER_PIN_CAMBODIA_MHEALTH_SOURCE_NUMBER`
  * The source number which determines the call is for mHealth
* `TWILREAPI_ACTIVE_CALL_ROUTER_PIN_CAMBODIA_MHEALTH_CALLER_ID`
  * The caller id to display for mHealth calls
* `TWILREAPI_ACTIVE_CALL_ROUTER_PIN_CAMBODIA_EWS_SOURCE_NUMBER`
  * The source number which determines the call is for EWS
* `TWILREAPI_ACTIVE_CALL_ROUTER_PIN_CAMBODIA_EWS_CALLER_ID`
  * The caller id to display for EWS calls

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/somleng/twilreapi-active_call_router-pin_cambodia.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


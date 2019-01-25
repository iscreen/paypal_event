# PaypalEvent

[![Gem Downloads](http://ruby-gem-downloads-badge.herokuapp.com/paypal_event?type=total)](https://rubygems.org/gems/paypal_event)
[![Build Status](https://travis-ci.org/iscreen/paypal_event.svg?branch=master)](https://travis-ci.org/iscreen/paypal_event)
[![Code Climate](https://codeclimate.com/github/iscreen/paypal_event.svg)](https://codeclimate.com/github/iscreen/paypal_event)
[![Inline docs](https://inch-ci.org/github/iscreen/paypal_event.svg?branch=master)](http://www.rubydoc.info/gems/paypal_event)

PaypalEvent is built on the [ActiveSupport::Notifications API](http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html). Incoming webhook requests are [authenticated with the webhook signature](#authenticating-webhooks-with-signatures). Define subscribers to handle specific event types. Subscribers can be a block or an object that responds to `#call`.

This project is refer to [StripeEvent](https://github.com/integrallis/stripe_event)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'paypal_event'
```

And then execute:

  $ bundle

Or install it yourself as:

  $ gem install paypal_event

## Usage

```ruby
# config/initializers/paypal.rb

PaypalEvent.configure do |events|
  events.subscribe 'PAYMENT.SALE.COMPLETED' do |event|
    # Define subscriber behavior based on the event object
    event[:event_type]        #=> 'PAYMENT.SALE.COMPLETED'
  end

  events.all do |event|
    # Handle all event types - logging, etc.
  end
end
```

### Subscriber objects that respond to #call

```ruby
class PaymentSaleCompleted
  def call(event)
    # Event handling
  end
end

class BillingEventLogger
  def initialize(logger)
    @logger = logger
  end

  def call(event)
    @logger.info "BILLING:#{event[:event_type]}:#{event[:id]}"
  end
end
```

```ruby
PaypalEvent.configure do |events|
  events.all BillingEventLogger.new(Rails.logger)
  events.subscribe 'PAYMENT.SALE.COMPLETED', PaymentSaleCompleted.new
end
```

### Subscribing to a namespace of event types

```ruby
PaymentEvent.subscribe 'PAYMENT.SALE.' do |event|
  # Will be triggered for any PAYMENT.SALE.* events
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/paypal_event.

### License

[MIT License](https://github.com/iscreen/paypal_event/blob/master/LICENSE.md). Copyright 2019-2020 Integrallis Software.

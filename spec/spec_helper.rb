# frozen_string_literal: true

require 'coveralls'
Coveralls.wear!

require 'bundler/setup'
require 'paypal_event'
require 'webmock/rspec'
Dir[File.expand_path('../spec/support/**/*.rb', __FILE__)].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    @event_filter = PaypalEvent.event_filter
    @notifier = PaypalEvent.backend.notifier
    PaypalEvent.backend.notifier = @notifier.class.new
  end

  config.after do
    PaypalEvent.event_filter = @event_filter
    PaypalEvent.backend.notifier = @notifier
  end
end

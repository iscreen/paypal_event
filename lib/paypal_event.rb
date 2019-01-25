# frozen_string_literal: true

require 'paypal_event/version'
require 'active_support/notifications'
require 'paypal-sdk-rest'
require 'paypal_event/engine' if defined?(Rails)
require 'paypal_event/util'

module PaypalEvent
  class << self
    attr_accessor :adapter, :backend, :namespace, :event_filter
    attr_reader :signing_secrets

    def configure(&block)
      raise ArgumentError, 'must provide a block' unless block_given?
      block.arity.zero? ? instance_eval(&block) : yield(self)
    end
    alias :setup :configure

    def instrument(event)
      event = event_filter.call(event)
      backend.instrument namespace.call(event[:event_type]), event if event
    end

    def subscribe(name, callable = Proc.new)
      backend.subscribe namespace.to_regexp(name), adapter.call(callable)
    end

    def all(callable = Proc.new)
      subscribe nil, callable
    end

    def listening?(name)
      namespaced_name = namespace.call(name)
      backend.notifier.listening?(namespaced_name)
    end
  end

  class Namespace < Struct.new(:value, :delimiter)
    def call(name = nil)
      "#{value}#{delimiter}#{name}"
    end

    def to_regexp(name = nil)
      %r{^#{Regexp.escape call(name)}}
    end
  end

  class NotificationAdapter < Struct.new(:subscriber)
    def self.call(callable)
      new(callable)
    end

    def call(*args)
      payload = args.last
      subscriber.call(payload)
    end
  end

  class Error < StandardError; end
  class UnauthorizedError < Error; end
  class SignatureVerificationError < Error; end

  self.adapter = NotificationAdapter
  self.backend = ActiveSupport::Notifications
  self.namespace = Namespace.new('paypal_event', '.')
  self.event_filter = lambda { |event| event }
end

# frozen_string_literal: true
require 'spec_helper'

RSpec.describe PaypalEvent do

  let(:events) { [] }
  let(:subscriber) { ->(evt){ events << evt } }

  let(:billing_subscription_created) {
    PaypalEvent::Util.symbolize_names(
      {
        'id' => 'evt_billing_subscription_created', 'event_type' => 'BILLING.SUBSCRIPTION.CREATED'
      }
    )
  }
  let(:billing_subscription_cancelled) {
    PaypalEvent::Util.symbolize_names(
      {
        'id' => 'evt_billing_subscription_cancelled', 'event_type' => 'BILLING.SUBSCRIPTION.CANCELLED'
      }
    )
  }
  let(:payment_created) {
    PaypalEvent::Util.symbolize_names(
      {
        'id' => 'evt_payment_created', 'event_type' => 'PAYMENT.ORDER.CREATED'
      }
    )
  }
  let(:payment_cancelled) {
    PaypalEvent::Util.symbolize_names(
      {
        'id' => 'evt_payment_cancelled', 'event_type' => 'PAYMENT.ORDER.CANCELLED'
      }
    )
  }

  it 'has a version number' do
    expect(PaypalEvent::VERSION).not_to be nil
  end

  describe '.configure' do
    it 'yields itself to the block' do
      yielded = nil
      PaypalEvent.configure { |events| yielded = events }
      expect(yielded).to eq PaypalEvent
    end
    it 'requires a block argument' do
      expect { PaypalEvent.configure }.to raise_error ArgumentError
    end

    describe '.setup - deprecated' do
      it 'evaluates the block in its own context' do
        ctx = nil
        PaypalEvent.setup { ctx = self }
        expect(ctx).to eq PaypalEvent
      end
    end
  end

  describe 'subscribing to a specific event type' do
    context 'with a block subscriber' do
      it 'calls the subscriber with the retrieved event' do
        PaypalEvent.subscribe('BILLING.SUBSCRIPTION.CREATED', &subscriber)

        PaypalEvent.instrument(billing_subscription_created)

        expect(events).to eq [billing_subscription_created]
      end
    end

    context "with a subscriber that responds to #call" do
      it "calls the subscriber with the retrieved event" do
        PaypalEvent.subscribe('BILLING.SUBSCRIPTION.CREATED', subscriber)

        PaypalEvent.instrument(billing_subscription_created)

        expect(events).to eq [billing_subscription_created]
      end
    end
  end

  describe "subscribing to a namespace of event types" do
    context "with a block subscriber" do
      it "calls the subscriber with any events in the namespace" do
        PaypalEvent.subscribe('PAYMENT.ORDER', &subscriber)

        PaypalEvent.instrument(payment_created)
        PaypalEvent.instrument(payment_cancelled)

        expect(events).to eq [payment_created, payment_cancelled]
      end
    end

    context "with a subscriber that responds to #call" do
      it "calls the subscriber with any events in the namespace" do
        PaypalEvent.subscribe('PAYMENT.ORDER.', subscriber)

        PaypalEvent.instrument(payment_created)
        PaypalEvent.instrument(payment_cancelled)

        expect(events).to eq [payment_created, payment_cancelled]
      end
    end
  end

  describe 'subscribing to all event types' do
    context 'with a block subscriber' do
      it 'calls the subscriber with all retrieved events' do
        PaypalEvent.all(&subscriber)

        PaypalEvent.instrument(billing_subscription_created)
        PaypalEvent.instrument(billing_subscription_cancelled)

        expect(events).to eq [billing_subscription_created, billing_subscription_cancelled]
      end
    end

    context 'with a subscriber that responds to #call' do
      it 'calls the subscriber with all retrieved events' do
        PaypalEvent.all(subscriber)

        PaypalEvent.instrument(billing_subscription_created)
        PaypalEvent.instrument(billing_subscription_cancelled)

        expect(events).to eq [billing_subscription_created, billing_subscription_cancelled]
      end
    end
  end

  describe '.listening?' do
    it 'returns true when there is a subscriber for a matching event type' do
      PaypalEvent.subscribe('PAYMENT.', &subscriber)

      expect(PaypalEvent.listening?('PAYMENT.ORDER.CREATED')).to be true
      expect(PaypalEvent.listening?('PAYMENT.ORDER.')).to be true
    end

    it 'returns false when there is not a subscriber for a matching event type' do
      PaypalEvent.subscribe('PAYMENT.ORDER.', &subscriber)

      expect(PaypalEvent.listening?('CUSTOMER')).to be false
    end

    it 'returns true when a subscriber is subscribed to all events' do
      PaypalEvent.all(&subscriber)

      expect(PaypalEvent.listening?('MERCHANT.')).to be true
      expect(PaypalEvent.listening?('CUSTOMER')).to be true
    end
  end

  describe PaypalEvent::NotificationAdapter do
    let(:adapter) { PaypalEvent.adapter }

    it 'calls the subscriber with the last argument' do
      expect(subscriber).to receive(:call).with(:last)

      adapter.call(subscriber).call(:first, :last)
    end
  end

  describe PaypalEvent::Namespace do
    let(:namespace) { PaypalEvent.namespace }

    describe '#call' do
      it 'prepends the namespace to a given string' do
        expect(namespace.call('foo.bar')).to eq 'paypal_event.foo.bar'
      end

      it 'returns the namespace given no arguments' do
        expect(namespace.call).to eq 'paypal_event.'
      end
    end

    describe '#to_regexp' do
      it 'matches namespaced strings' do
        expect(namespace.to_regexp('foo.bar')).to match namespace.call('foo.bar')
      end

      it 'matches all namespaced strings given no arguments' do
        expect(namespace.to_regexp).to match namespace.call('foo.bar')
      end
    end
  end
end

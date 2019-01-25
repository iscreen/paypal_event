# frozen_string_literal: true

module PaypalEvent
  class WebhookController < ActionController::Base
    include PayPal::SDK::REST
    include PayPal::SDK::Core::Logging

    if Rails.application.config.action_controller.default_protect_from_forgery
      skip_before_action :verify_authenticity_token
    end

    def event
      PaypalEvent.instrument(PaypalEvent::Util.symbolize_names(verified_event))
      head :ok
    rescue StandardError => e
      log_error(e)
      head :bad_request
    end

    private

    def verified_event
      actual_signature = request.headers['Paypal-Transmission-Sig']
      auth_algo      = request.headers['Paypal-Auth-Algo']
      auth_algo.sub!(/withRSA/i, '')
      cert_url        = request.headers['Paypal-Cert-Url']
      transmission_id  = request.headers['Paypal-Transmission-Id']
      timestamp      = request.headers['Paypal-Transmission-Time']
      webhook_id     = ENV['PAYPAL_WEBHOOK_ID'] #The webhook_id provided by PayPal when webhook is created on the PayPal developer site
      event_body     = params[:paypal].to_json

      valid = WebhookEvent.verify(transmission_id, timestamp, webhook_id, event_body, cert_url, actual_signature, auth_algo)
      unless valid
        message = "webhook event #{webhook_id} validation failed"
        logger.error message
        raise PaypalEvent::SignatureVerificationError.new(message, http_body: event_body)
      end
      event_body
    end

    def log_error(e)
      logger.error e.message
      e.backtrace.each { |line| logger.error "  #{line}" }
    end
  end
end
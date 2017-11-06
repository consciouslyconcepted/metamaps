# frozen_string_literal: true

class WebhookService
  def self.publish!(webhook:, event:)
    return false unless webhook.event_types.include? event.kind
    HTTParty.post webhook.uri, body: payload_for(webhook, event), headers: webhook.headers
  end

  class << self
    def payload_for(webhook, event)
      WebhookSerializer.new(webhook_object_for(webhook, event), root: false).to_json
    end

    def webhook_object_for(webhook, event)
      "Webhooks::#{webhook.kind.classify}::#{event.kind.classify}".constantize.new(webhook, event)
    end
  end
end

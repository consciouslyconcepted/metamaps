# frozen_string_literal: true

module Events
  class TopicUpdated < Event
    # after_create :notify_users!

    def self.publish!(topic, user, meta)
      create!(kind: 'topic_updated',
              eventable: topic,
              user: user,
              meta: meta)
    end

    def notify_users!
      NotificationService.notify_followers(eventable, 'topic_updated', self)
    end
  end
end

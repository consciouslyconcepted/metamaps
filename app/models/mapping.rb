# frozen_string_literal: true

class Mapping < ApplicationRecord
  scope :topicmapping, -> { where(mappable_type: :Topic) }
  scope :synapsemapping, -> { where(mappable_type: :Synapse) }

  belongs_to :mappable, polymorphic: true
  belongs_to :map, class_name: 'Map', foreign_key: 'map_id', touch: true
  belongs_to :user
  belongs_to :updated_by, class_name: 'User'

  validates :map, presence: true
  validates :mappable, presence: true

  delegate :name, to: :user, prefix: true

  after_create :after_created
  after_create :after_created_async
  after_update :after_updated
  after_update :after_updated_async
  before_destroy :before_destroyed

  def user_image
    user.image.url
  end

  def as_json(_options = {})
    super(methods: %i(user_name user_image))
  end

  def after_created
    if mappable_type == 'Topic'
      ActionCable.server.broadcast 'map_' + map.id.to_s, type: 'topicAdded', topic: mappable.filtered, mapping_id: id
      meta = { 'x': xloc, 'y': yloc, 'mapping_id': id }
      Events::TopicAddedToMap.publish!(mappable, map, user, meta)
    elsif mappable_type == 'Synapse'
      ActionCable.server.broadcast(
        'map_' + map.id.to_s,
        type: 'synapseAdded',
        synapse: mappable.filtered,
        topic1: mappable.topic1&.filtered,
        topic2: mappable.topic2&.filtered,
        mapping_id: id
      )
      meta = { 'mapping_id': id }
      Events::SynapseAddedToMap.publish!(mappable, map, user, meta)
    end
  end

  def after_created_async
    FollowService.follow(map, user, 'contributed')
  end
  handle_asynchronously :after_created_async

  def after_updated
    return unless (mappable_type == 'Topic') && (xloc_changed? || yloc_changed?)
    meta = { 'x': xloc, 'y': yloc, 'mapping_id': id }
    Events::TopicMovedOnMap.publish!(mappable, map, updated_by, meta)
    ActionCable.server.broadcast('map_' + map.id.to_s, type: 'topicMoved',
                                 id: mappable.id, mapping_id: id,
                                 x: xloc, y: yloc)
  end

  def after_updated_async
    return unless (mappable_type == 'Topic') && (xloc_changed? || yloc_changed?)
    FollowService.follow(map, updated_by, 'contributed')
  end
  handle_asynchronously :after_updated_async

  def before_destroyed
    if mappable.defer_to_map
      mappable.permission = mappable.defer_to_map.permission
      mappable.defer_to_map_id = nil
      mappable.save
    end

    meta = { 'mapping_id': id }
    if mappable_type == 'Topic'
      Events::TopicRemovedFromMap.publish!(mappable, map, updated_by, meta)
      ActionCable.server.broadcast 'map_' + map.id.to_s, type: 'topicRemoved', id: mappable.id, mapping_id: id
    elsif mappable_type == 'Synapse'
      Events::SynapseRemovedFromMap.publish!(mappable, map, updated_by, meta)
      ActionCable.server.broadcast 'map_' + map.id.to_s, type: 'synapseRemoved', id: mappable.id, mapping_id: id
    end
    FollowService.follow(map, updated_by, 'contributed')
  end
end

# frozen_string_literal: true

class InMetacodeSet < ApplicationRecord
  belongs_to :metacode, class_name: 'Metacode', foreign_key: 'metacode_id'
  belongs_to :metacode_set, class_name: 'MetacodeSet', foreign_key: 'metacode_set_id'
end

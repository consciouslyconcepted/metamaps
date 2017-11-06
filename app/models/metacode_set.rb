# frozen_string_literal: true

class MetacodeSet < ApplicationRecord
  belongs_to :user
  has_many :in_metacode_sets
  has_many :metacodes, through: :in_metacode_sets
end

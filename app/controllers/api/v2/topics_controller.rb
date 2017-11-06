# frozen_string_literal: true

module Api
  module V2
    class TopicsController < WithUpdatesController
      def searchable_columns
        %i[name desc link]
      end
    end
  end
end

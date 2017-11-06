# frozen_string_literal: true

class SearchController < ApplicationController
  include TopicsHelper
  include MapsHelper
  include UsersHelper
  include SynapsesHelper

  before_action :authorize_search
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: %i[maps mappers synapses topics]

  # get /search/topics?term=SOMETERM
  def topics
    term = params[:term]
    user = params[:user] ? params[:user] : false

    if term.present? && term.downcase[0..3] != 'map:' &&
       term.downcase[0..6] != 'mapper:' && !term.casecmp('topic:').zero?

      # remove "topic:" if appended at beginning
      term = term[6..-1] if term.downcase[0..5] == 'topic:'

      # if desc: search desc instead
      desc = false
      if term.downcase[0..4] == 'desc:'
        term = term[5..-1]
        desc = true
      end

      # if link: search link instead
      link = false
      if term.downcase[0..4] == 'link:'
        term = term[5..-1]
        link = true
      end

      # check whether there's a filter by metacode as part of the query
      filter_by_metacode = false
      Metacode.all.each do |m|
        length_one = m.name.length + 1
        length_two = m.name.length

        if term.downcase[0..length_two] == m.name.downcase + ':'
          term = term[length_one..-1]
          filter_by_metacode = m
        end
      end

      search = '%' + term.downcase.strip + '%'
      builder = policy_scope(Topic)

      if filter_by_metacode
        if term == ''
          builder = builder.none
        else
          builder = builder.where('LOWER("name") like ? OR
                                   LOWER("desc") like ? OR
                                   LOWER("link") like ?', search, search, search)
          builder = builder.where(metacode_id: filter_by_metacode.id)
        end
      elsif desc
        builder = builder.where('LOWER("desc") like ?', search)
      elsif link
        builder = builder.where('LOWER("link") like ?', search)
      else # regular case, just search the name
        builder = builder.where('LOWER("name") like ? OR
                                 LOWER("desc") like ? OR
                                 LOWER("link") like ?', search, search, search)
      end

      builder = builder.where(user: user) if user
      @topics = builder.order(:name)
    else
      skip_policy_scope
      @topics = []
    end

    render json: autocomplete_array_json(@topics).to_json
  end

  # get /search/maps?term=SOMETERM
  def maps
    term = params[:term]
    user = params[:user] ? params[:user] : nil

    if term.present? && term.downcase[0..5] != 'topic:' &&
       term.downcase[0..6] != 'mapper:' && !term.casecmp('map:').zero?

      # remove "map:" if appended at beginning
      term = term[4..-1] if term.downcase[0..3] == 'map:'

      # if desc: search desc instead
      desc = false
      if term.downcase[0..4] == 'desc:'
        term = term[5..-1]
        desc = true
      end

      search = '%' + term.downcase.strip + '%'
      builder = policy_scope(Map)

      builder = if desc
                  builder.where('LOWER("desc") like ?', search)
                else
                  builder.where('LOWER("name") like ?', search)
                end
      builder = builder.where(user: user) if user
      @maps = builder.order(:name)
    else
      skip_policy_scope
      @maps = []
    end

    render json: autocomplete_map_array_json(@maps).to_json
  end

  # get /search/mappers?term=SOMETERM
  def mappers
    term = params[:term]
    if term.present? && term.downcase[0..3] != 'map:' &&
       term.downcase[0..5] != 'topic:' && !term.casecmp('mapper:').zero?

      # remove "mapper:" if appended at beginning
      term = term[7..-1] if term.downcase[0..6] == 'mapper:'
      search = term.downcase.strip + '%'

      builder = policy_scope(User).where('LOWER("name") like ?', search)
      @mappers = builder.order(:name)
    else
      skip_policy_scope
      @mappers = []
    end
    render json: autocomplete_user_array_json(@mappers).to_json
  end

  # get /search/synapses?term=SOMETERM OR
  # get /search/synapses?topic1id=SOMEID&topic2id=SOMEID
  def synapses
    term = params[:term]
    topic1id = params[:topic1id]
    topic2id = params[:topic2id]

    if term.present?
      @synapses = policy_scope(Synapse)
                  .where('LOWER("desc") like ?', '%' + term.downcase.strip + '%')
                  .order('"desc"')

      @synapses = @synapses.uniq(&:desc)
    elsif topic1id.present?
      one = policy_scope(Synapse).where(topic1_id: topic1id, topic2_id: topic2id)
      two = policy_scope(Synapse).where(topic2_id: topic1id, topic1_id: topic2id)
      @synapses = one + two
      @synapses.sort! { |s1, s2| s1.desc <=> s2.desc }.to_a
    else
      skip_policy_scope
      @synapses = []
    end

    # limit to 5 results
    @synapses = @synapses.to_a.slice(0, 5)

    render json: autocomplete_synapse_array_json(@synapses).to_json
  end

  private

  def authorize_search
    authorize :Search
  end
end

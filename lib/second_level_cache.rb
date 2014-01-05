# -*- encoding : utf-8 -*-
require 'active_support/core_ext'
require 'second_level_cache/config'
require 'second_level_cache/parser'
require 'second_level_cache/store'

module SecondLevelCache
  def self.configure
    block_given? ? yield(Config) : Config
  end

  class << self
    delegate :logger, :cache_store, :cache_key_prefix, :expires_in, :to => Config
  end

  module Mixin
    extend ActiveSupport::Concern

    module ClassMethods
      attr_reader :second_level_cache_options

      def acts_as_cached(options = {})
        @second_level_cache_enabled = Config.second_level_cache_enabled?
        @second_level_cache_options = options
        @second_level_cache_options[:expires_in] ||= Config.expires_in
        @second_level_cache_options[:version] ||= 0
        relation.class.send :include, SecondLevelCache::ActiveRecord::FinderMethods
      end

      def second_level_cache_enabled?
        !!@second_level_cache_enabled
      end

      def without_second_level_cache
        old, @second_level_cache_enabled = @second_level_cache_enabled, false

        yield if block_given?
      ensure
        @second_level_cache_enabled = old
      end

      def cache_version
        second_level_cache_options[:version]
      end

      def second_level_cache_key(id)
        "#{Config.cache_key_prefix}/#{name.downcase}/#{id}/#{cache_version}"
      end

      def read_second_level_cache(id)
        if self.second_level_cache_enabled?
          Config.logger.debug "SLC GET: #{self.name}/#{id}"
          SecondLevelCache.cache_store.get(second_level_cache_key(id))
        end
      end

      def expire_second_level_cache(id)
        if self.second_level_cache_enabled?
          Config.logger.debug "SLC DEL: #{self.name}/#{id}"
          SecondLevelCache.cache_store.delete(second_level_cache_key(id))
        end
      end
    end

    def second_level_cache_key
      self.class.second_level_cache_key(id)
    end

    def expire_second_level_cache
      if self.class.second_level_cache_enabled?
        Config.logger.debug "SLC DEL: #{self.class.name}/#{id}"
        SecondLevelCache.cache_store.delete(second_level_cache_key)
      end
    end

    def write_second_level_cache
      if self.class.second_level_cache_enabled?
        Config.logger.debug "SLC SET: #{self.class.name}/#{id} (expires_in: #{self.class.second_level_cache_options[:expires_in]})"
        SecondLevelCache.cache_store.set(second_level_cache_key, self, :expires_in => self.class.second_level_cache_options[:expires_in])
      end
    end

    def update_second_level_cache
      if self.class.second_level_cache_enabled?
        Config.logger.debug "SLC UPDATE: #{self.class.name}/#{id} (expires_in: #{self.class.second_level_cache_options[:expires_in]})"
        SecondLevelCache.cache_store.set(second_level_cache_key, self.reload, :expires_in => self.class.second_level_cache_options[:expires_in])
      end
    end

  end
end

require 'second_level_cache/active_record' if defined?(ActiveRecord)

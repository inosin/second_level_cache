# -*- encoding : utf-8 -*-
module SecondLevelCache
  module Config
    extend self

    attr_accessor :cache_store, :logger, :cache_key_prefix, :expires_in

    def cache_store
      @cache_store ||= SecondLevelCache::Store::Memory.new(50)
      @cache_store
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def cache_key_prefix
      @cache_key_prefix ||= 'slc'
    end

    def expires_in
      @expires_in ||= 1.week
    end

    def second_level_cache_enabled?
      @cache_store.is_a?(SecondLevelCache::Store::Base)
    end

  end
end

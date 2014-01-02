module SecondLevelCache
    ##
    # Defines the available storage adapters for persisting the cache.
    #
  module Store
    # The defined duration for the expiration edge.
    EXPIRES_EDGE = 86400

    autoload :Base,     'second_level_cache/store/base'
    autoload :Memcached, 'second_level_cache/store/memcached'
    autoload :Dalli,    'second_level_cache/store/dalli'
    autoload :Memory,   'second_level_cache/store/memory'
    autoload :Redis,    'second_level_cache/store/redis'
  end
end

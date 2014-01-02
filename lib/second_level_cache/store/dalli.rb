module SecondLevelCache
  module Store
    ##
    # Memcache Cache Store
    #
    class Dalli < Base
      ##
      # Initialize dalli client store with client connection.
      #
      # @param client
      #   instance of Dalli::Client library
      #
      # @example
      #   config.cache_store = SecondLevelCache::Store::Dalli.new(::Dalli::Client.new('127.0.0.1:11211'))
      #
      def initialize(client, options={})
        @backend = client
        super(options)
        @never = 0  # never TTL in Memcache is 0
      end

      ##
      # Return the value for the given key.
      #
      # @param [String] key
      #   cache key to retrieve value
      #
      # @example
      #   MyApp.cache.get('records')
      #
      def get(key)
        code = @backend.get(key)
        return nil unless code
        parser.decode(code)
      rescue ::Dalli::DalliError
        nil
      end

      ##
      # Return the values for the given keys.
      #
      # @param [Array] keys
      #   cache keys to retrieve value
      #
      # @example
      #   MyApp.cache.get_multi('record1', 'record2', 'record3')
      #
      def get_multi(*keys)
        codes = @backend.get_multi(keys)
        return [] if codes.empty?
        parser.decode_multi(codes.values)
      rescue ::Dalli::DalliError
        nil
      end

      ##
      # Set the value for a given key and optionally with an expire time.
      # Default expiry time is 86400.
      #
      # @param [String] key
      #   cache key
      # @param value
      #   value of cache key
      #
      # @example
      #   MyApp.cache.set('records', records)
      #   MyApp.cache.set('records', records, :expires_in => 30) # => 30 seconds
      #
      def set(key, value, opts = nil)
        value = parser.encode(value)
        @backend.set(key, value, get_expiry(opts))
      rescue ::Dalli::DalliError
        nil
      end

      ##
      # Delete the value for a given key.
      #
      # @param [String] key
      #   cache key
      #
      # @example
      #   MyApp.cache.delete('records')
      #
      def delete(key)
        @backend.delete(key)
      rescue ::Dalli::DalliError
        nil
      end

      ##
      # Reinitialize your cache.
      #
      # @example
      #   MyApp.cache.flush
      #   MyApp.cache.get('records') # => nil
      #
      def flush
        @backend.respond_to?(:flush_all) ? @backend.flush_all : @backend.flush
      rescue ::Dalli::DalliError
        nil
      end
    end
  end
end

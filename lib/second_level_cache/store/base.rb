module SecondLevelCache
  module Store
    ##
    # Abstract Cache Store
    #
    class Base
      ##
      # Get the cache parser strategy.
      #
      def parser
        @_parser
      end

      def initialize(options={})
        @never = -1
        self.parser = self.is_a?(SecondLevelCache::Store::Redis) ? :marshal : :plain
      end

      private

      def parser=(mod)
        mod = SecondLevelCache::Parser.const_get(mod.to_s.camelize) unless mod.is_a?(Module)
        raise "#{mod} should respond to encode" unless mod.respond_to?(:encode)
        raise "#{mod} should respond to decode" unless mod.respond_to?(:decode)
        @_parser=mod
      end

      def get_expiry( opts )
        if opts && opts[:expires_in] && opts[:expires_in] != -1
          expires_in = opts[:expires_in].to_i
          expires_in = EXPIRES_EDGE  if expires_in > EXPIRES_EDGE
          Time.now.to_i + expires_in
        else
          @never
        end
      end

      def now_before?( expiry )
        expiry.to_i == @never || expiry.to_i > Time.now.to_i
      end
    end
  end
end

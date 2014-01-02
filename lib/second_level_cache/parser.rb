module SecondLevelCache
  ##
  # Defines a parser for our cache store.
  #
  module Parser
    module Base
      def decode_multi(serializeds)
        serializeds.map{|serialized| decode(serialized)}
      end
    end
    ##
    # With Parser::Plain we will store
    # text and object in a text format.
    #
    module Plain
      extend Base
      def self.encode(code)
        code.is_a?(ActiveRecord::Base) ?
         [code.class.name,
          code.attributes
        ] : code
      end

      def self.decode(code)
        return unless code
        return code unless code.is_a?(Array)
        record = code[0].constantize.allocate
        record.init_with('attributes' => code[1])
        record
      end
    end

    ##
    # With Parser::Marshal we will store
    # text and object in a marshaled format.
    #
    module Marshal
      extend Base
      def self.encode(code)
        ::Marshal.dump(code.is_a?(ActiveRecord::Base) ? [
          code.class.name,
          code.attributes
        ] : code)
      end

      # load a cached record
      def self.decode(code)
        return unless code
        serialized = ::Marshal.load code
        return serialized unless serialized.is_a?(Array)
        record = serialized[0].constantize.allocate
        record.init_with('attributes' => serialized[1])
        record
      end
    end

  end
end

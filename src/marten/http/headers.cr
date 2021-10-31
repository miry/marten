module Marten
  module HTTP
    # Represents a set of HTTP headers extracted from an HTTP request.
    class Headers
      include Enumerable({String, Array(String)})

      def initialize(@headers : ::HTTP::Headers)
      end

      def initialize
        @headers = ::HTTP::Headers.new
      end

      # Returns true if the other headers object corresponds to the current headers.
      def ==(other : self)
        super || (to_stdlib == other.to_stdlib)
      end

      # Returns the first value associated with the passed header name.
      def [](name : String | Symbol)
        headers[name.to_s]
      end

      # Returns the first value associated with the passed header name or `nil` if the header is not present.
      def []?(name : String | Symbol)
        headers[name.to_s]?
      end

      # Allows to set a specific header.
      def []=(name : String | Symbol, value)
        headers[name.to_s] = value.to_s
      end

      # Deletes a specific header and return its value, or `nil` if the header does not exist.
      def delete(name : String | Symbol) : String?
        headers.delete(name.to_s)
      end

      # Returns `true` if the header with the provided name exists.
      def has_key?(name : String | Symbol) # ameba:disable Style/PredicateName
        headers.has_key?(name.to_s)
      end

      # Returns the value of the specified header name or fallback to the provided default value ( which is `nil`by
      # default).
      def fetch(name : String | Symbol, default = nil)
        headers.fetch(name.to_s, default)
      end

      # Allows to iterate over all the headers.
      delegate each, to: headers

      # Returns `true` if there are no headers.
      delegate empty?, to: headers

      # Returns the number of headers.
      delegate size, to: headers

      protected def to_stdlib
        headers
      end

      private getter headers
    end
  end
end

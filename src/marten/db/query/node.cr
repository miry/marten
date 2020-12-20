module Marten
  module DB
    module Query
      class Node
        alias FilterHash = Hash(String | Symbol, Field::Any | Array(Field::Any) | DB::Model)

        def initialize(
          @children = [] of self,
          @connector = SQL::PredicateConnector::AND,
          @negated = false,
          **kwargs
        )
          @filters = FilterHash.new
          fill_filters(kwargs)
        end

        def initialize(
          filters : Hash | NamedTuple,
          @children = [] of self,
          @connector = SQL::PredicateConnector::AND,
          @negated = false
        )
          @filters = FilterHash.new
          fill_filters(filters)
        end

        def initialize(
          @children : Array(self),
          @connector : SQL::PredicateConnector,
          @negated : Bool,
          @filters : FilterHash
        )
        end

        def ==(other : self)
          (
            (other.filters == @filters) &&
              (other.children == @children) &&
              (other.connector == @connector) &&
              (other.negated == @negated)
          )
        end

        def &(other : self)
          combine(other, SQL::PredicateConnector::AND)
        end

        def |(other : self)
          combine(other, SQL::PredicateConnector::OR)
        end

        def - : self
          negated_parent = self.class.new
          negated_parent.add(self, SQL::PredicateConnector::AND)
          negated_parent.negate
          negated_parent
        end

        protected getter children
        protected getter connector
        protected getter filters
        protected getter negated

        protected def add(other : self, conn : SQL::PredicateConnector)
          return if @children.includes?(other)

          if @connector == conn
            @children << other
          else
            new_child = self.class.new(children: @children, connector: @connector, negated: @negated, filters: @filters)
            @connector = conn
            @children = [new_child, other]
          end
        end

        protected def negate
          @negated = !@negated
        end

        private def combine(other, conn)
          combined = self.class.new(connector: conn)
          combined.add(self, conn)
          combined.add(other, conn)
          combined
        end

        private def fill_filters(filters)
          filters.each do |key, value|
            @filters[key] = case value
                            when Array
                              arr = Array(Field::Any).new
                              value.each { |v| arr << v }
                              arr
                            else
                              value
                            end
          end
        end
      end
    end
  end
end
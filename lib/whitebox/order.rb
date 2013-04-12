module Whitebox
  class Order
    attr_accessor :datapoint, :amount
    @@orders = []

    def initialize(datapoint, amount)
      # correct formating
      @datapoint = datapoint.each_with_object({}) do |(key, value), obj|
        obj[key] = key == :date ? value : value.to_f
      end
      @amount = amount
    end

    class << self

      def make(datapoint, amount)
        @@orders << new(datapoint, amount)
        puts "Made an order at #{datapoint[:date]} @ #{datapoint[:close]} * #{amount}"
      end

      def clear
        @@orders = []
      end

      def all
        @@orders
      end

    end
  end
end
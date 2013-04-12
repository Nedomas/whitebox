module Whitebox
  class Order
    attr_accessor :action, :price, :amount
    def initialize(action, price, amount)
      @action = action
      @amount = amount
      @price = price
      return self
    end
  end
end
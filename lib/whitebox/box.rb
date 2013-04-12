module Whitebox
  class Box
    attr_accessor :data, :toggle, :orders, :balance, :amount, :skip

    def initialize
      @orders ||= []
      @data = Securities::Stock.new(symbol: 'AAPL', start_date: '2012-01-01').output
    end

    def run
      @data.each_with_index do |datapoint, i|
        each_datapoint(datapoint, @data.first(i+1))
      end
      @balance ||= 0
      @amount ||= 0
      @orders.each do |order|
        cost = order.price * order.amount
        if order.action == :open
          @balance += cost
          @amount += order.amount
        elsif order.action == :close && @amount >= order.amount
          @balance -= cost
          @amount -= order.amount
        else
          puts "Skipped #{order.inspect}"
          puts "because balance #{@amount} >= #{order.amount} && action = #{order.action}"
        end
      end
      puts "Skip count: #{@skip}."
      puts "Orders count: #{@orders.count}"
      puts "Balance: #{@balance}"
    end

    def toggle(which)
      @toggle ||= which # setting for the first time
      @toggle != which and @toggle = which
    end

    def each_datapoint(datapoint, current_data)
      # puts "Processing: #{datapoint[:date]}"
      indicator_data = Indicators::Data.new(current_data)
      sma_15 = indicator_data.calc(type: :sma, params: 15).output.last
      sma_20 = indicator_data.calc(type: :sma, params: 20).output.last

      if sma_15 > sma_20 && toggle(:over)
        @orders << Order.new(:open, datapoint[:close].to_f, 1)
        puts "#{sma_15} now over #{sma_20}"
      elsif sma_15 < sma_20 && toggle(:under)
        @orders << Order.new(:close, datapoint[:close].to_f, -1)
        puts "#{sma_15} now under #{sma_20}"
      end

    rescue
      @skip ||= 0
      @skip += 1 
      puts "Skipping #{datapoint[:date]}"
    end
  end
end
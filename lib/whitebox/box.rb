module Whitebox
  class Box
    attr_accessor :data, :toggle, :balance, :amount, :skip, :toggles

    def initialize
      @data = Securities::Stock.new(symbol: 'AAPL', start_date: '2012-01-01').output
    end

    def run
      @balance = @amount = @skip = 0
      @toggles = {}

      Order.clear
      @data.each_with_index do |datapoint, i|
        @current_data = @data.first(i+1)
        each_datapoint(datapoint)
      end
      orders = Order.all

      orders.each do |order|
        @balance += order.datapoint[:close] * order.amount
        @amount += order.amount
      end

      puts "Skip count: #{@skip}."
      puts "Orders count: #{orders.count}"
      puts "Balance: #{@balance.round(2)}"
    end

    def each_datapoint(datapoint)

      if toggle { sma(15, 20) > sma(20) }
        Order.make(datapoint, 1)
        puts "#{sma(15, 20)} now over #{sma(20)}"
      elsif toggle { sma(100) < sma(200) }
        binding.pry
        Order.make(datapoint, -1)
        puts "#{sma(100)} now under #{sma(200)}"
      end

    rescue Indicators::Helper::HelperException
      @skip += 1
    end

    def method_missing(m, *args)
      @indicator_data ||= {}
      datakey = "#{@current_data.first[:date]} #{@current_data.last[:date]}"
      @indicator_data[datakey] = Indicators::Data.new(@current_data) unless @indicator_data[datakey]

      @indicator_data[datakey].calc(type: m, params: args).output.last
    rescue => e
      raise e
    end

    private

    def toggle(&rule)
      @toggles[rule.source_location] ||= rule.yield
      result = @toggles[rule.source_location] != rule.yield
      @toggles[rule.source_location] = rule.yield
      result
    end

  end
end
module Whitebox

  class Box

    attr_accessor :data, :balance, :amount, :skip, :toggles, :param

    def initialize(*data)
      @data = if data.first
        data.first
      else
        Securities::Stock.new(symbol: 'AAPL', start_date: '2013-01-01').output
      end
    end

    def run(opts = nil)
      @balance = @amount = @skip = 0
      @toggles = {}
      @opts = opts

      Order.clear
      @data.each_with_index do |datapoint, i|
        @current_data = @data.first(i+1)
        each_datapoint(datapoint)
      end
      orders = Order.all

      orders.each do |order|
        @balance += order.datapoint[:close] * order.amount
        @amount += order.amount
        @balance -= order.datapoint[:close] * order.amount.abs * 0.05 # spread
      end

      puts "Skip count: #{@skip}."
      puts "Orders count: #{orders.count}"
      puts "Balance: #{@balance.round(2)}"
    end

    def method_missing(m, *args)
      @indicator_data ||= {}
      datakey = "#{@current_data.first[:date]} #{@current_data.last[:date]}"
      @indicator_data[datakey] = Indicators::Data.new(@current_data) unless @indicator_data[datakey]
      @indicator_data[datakey].calc(type: m, params: args).output.last
    rescue => e

      if e.to_s.match(/Data point length/)
        @skip += 1
        MissingData.new
      else
        raise e
      end

    end

    def bruteforce
      data = Securities::Stock.new(symbol: 'AAPL', start_date: '2013-01-01').output
      results = {}
      force_range = 1..20
      indicators = [:sma, :ema]
      puts "Bruteforce range: #{force_range}"
      force_range.each do |param_1|
        force_range.each do |param_2|
          puts "Doing #{param_1} and #{param_2}"
          box = Whitebox::Box.new(data)
          opts = {indicators: indicators, params: [param_1, param_2]}
          box.run(opts)
          results[param_1] ||= {}
          results[param_1][param_2] = box.balance
        end
      end

      best = []
      results.each do |param_1, param_2_balance|
        sorted_param_2_balance = param_2_balance.sort_by(&:last).reverse
        sorted_param_2_balance.each do |param_2, balance|
          best << {param_1: param_1, param_2: param_2, balance: balance}
        end
      end

      printable = best.sort_by { |k,v| k[:balance] }.reverse
      puts "TOP COMBINATIONS"
      printable.take(10).each do |line|
        puts "P1 #{line[:param_1]}, P2 #{line[:param_2]} : #{line[:balance]}"
      end
    end

    private

    def each_datapoint(datapoint)

      if toggle { sma(@opts[:params][0]) > sma(@opts[:params][1]) }
        Order.make(datapoint, 1)
      elsif toggle { sma(@opts[:params][0]) < sma(@opts[:params][1]) }
        Order.make(datapoint, -1)
      end

    end

    def toggle(&rule)
      if rule.yield == :missing_data
        false
      else
        @toggles[rule.source_location] ||= rule.yield
        result = @toggles[rule.source_location] != rule.yield
        @toggles[rule.source_location] = rule.yield
        result
      end
    end

  end
end
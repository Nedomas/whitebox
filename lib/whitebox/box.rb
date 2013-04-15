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

    def run(context = nil)
      @balance = @amount = @skip = 0
      @toggles = {}
      @context = context

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
      results = {}
      force_range = 1..2
      indicators = [:sma, :ema]
      puts "Bruteforce range: #{force_range}"
      force_range.each do |param_1|
        force_range.each do |param_2|
          puts "Doing #{param_1} and #{param_2}"
          box = Whitebox::Box.new
          box.run(param_1: param_1, param_2: param_2)
          results[param_1] ||= {}
          results[param_1][param_2] = box.balance
        end
      end

      print_me = {}
      results.each do |param_1, param_2_balance|
        printable = param_2_balance.sort_by(&:last).reverse
        puts "TOP COMBINATIONS #{param_1}"
        print_me[param_1] ||= {}
        binding.pry
        print_me[param_1][param_2.first] = printable.take(2)
      end
      binding.pry

      printable = results.sort_by(&:last).reverse
      puts "TOP COMBINATIONS"
      printable.take(5).each_with_index do |(param, balance), index|
        puts "#{index}. P #{param} : #{balance}"
      end
    end

    private

    def each_datapoint(datapoint)

      if toggle { sma(@context[:param_1]) > sma(@context[:param_2]) }
        Order.make(datapoint, 1)
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
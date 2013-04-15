class Array

  aliases = { 0 => %w(middle macd fast), 1 => %w(upper signal slow), 2 => %w(lower histogram full)}

  aliases.each do |array_index, names|
    names.each { |name| define_method(name) { self[array_index] } }
  end

end

class MissingData

  def <(other)
    :missing_data
  end
  def >(other)
    :missing_data
  end

  def method_missing(m, *args)
    self
  end

end

class Float
  def <(other)
    other.class == MissingData ? :missing_data : super
  end
  def >(other)
    other.class == MissingData ? :missing_data : super
  end
end
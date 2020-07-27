class PartialDate
  def initialize(str)
    @str = str.tidy
  end

  def to_s
    # There must be a nicer way to do this
    shorttext.split('-').map { |num| num.rjust(2, "0") }.join('-')
  end

  private

  attr_reader :str

  def parts
    str.split(' ').reverse
  end

  def longtext
    parts.join('-')
  end

  def shorttext
    longtext.gsub(MONTHS_RE) { |name| MONTHS.find_index(name) }
  end

  MONTHS = %w(NULL January February March April May June July August September October November December)
  MONTHS_RE = Regexp.new(MONTHS.join('|'))
end

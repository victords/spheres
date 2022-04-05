class Match
  attr_accessor :type, :horizontal, :col, :row, :chain, :count

  def initialize(type, horizontal, col, row, chain)
    @type = type
    @horizontal = horizontal
    @col = col
    @row = row
    @chain = chain
    @count = 1
  end
end

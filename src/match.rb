require_relative 'constants'

class Match
  attr_accessor :type, :chain, :count
  attr_reader :col, :row, :score

  def initialize(type, horizontal, col, row, chain)
    @type = type
    @horizontal = horizontal
    @col = col
    @row = row
    @chain = chain
    @count = 1
  end

  def startup(objects)
    @score = MATCH_SCORE[@count - 3] * 2**@chain
    @duration = 12 + (@count - 3) * 6 + @chain * 12
    if @horizontal
      (@col...(@col + @count)).each do |i|
        objects[i][@row].locked = true
      end
    else
      (@row...(@row + @count)).each do |j|
        objects[@col][j].locked = true
      end
    end
  end

  def dead?
    @duration <= 0
  end

  def update(objects)
    if @horizontal
      (@col...(@col + @count)).each do |i|
        objects[i][@row]&.blink
      end
    else
      (@row...(@row + @count)).each do |j|
        objects[@col][j]&.blink
      end
    end

    @duration -= 1
    return if @duration > 0

    if @horizontal
      (@col...(@col + @count)).each do |i|
        ((@row + 1)...NUM_ROWS).each do |j|
          objects[i][j].chain!(@chain + 1) if objects[i][j].is_a?(Sphere)
        end
        objects[i][@row] = nil
      end
    else
      ((@row + @count)...NUM_ROWS).each do |j|
        objects[@col][j].chain!(@chain + 1) if objects[@col][j].is_a?(Sphere)
      end
      (@row...(@row + @count)).each do |j|
        objects[@col][j] = nil
      end
    end
  end

  def draw(margin)
    x = margin.x + (@col + ((@horizontal ? @count : 1) * 0.5)) * SPHERE_SIZE
    y = margin.y + (NUM_ROWS - @row - (@horizontal ? 1 : (@count + 1) * 0.5)) * SPHERE_SIZE + 2
    Game.text_helper.write_line(@score.to_s, x, y, :center, 0xffffff, 255, :border, 0x006666, 2, 127, 1, 1.5, 1.5)
  end
end

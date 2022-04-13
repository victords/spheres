require 'minigl'
require_relative 'constants'
require_relative 'sphere'
require_relative 'lock'

class Item
  attr_reader :type, :level, :arg

  def initialize(type, level)
    @type = type
    if type == :key
      @level = [2 * level, 20].min
    elsif type == :bomb
      @level = [level, 5].min
    elsif type == :line_converter
      @level = [level, 6].min
      @arg = BASIC_SPHERE_TYPES.sample
    end
  end

  def icon
    name = if @type == :line_converter
             :sprite_lineConverter
           else
             "sprite_#{@type}"
           end
    Res.img(name)
  end

  def use(game, objects, col, row)
    case @type
    when :key
      return false unless objects[col][row].is_a?(Lock) && objects[col][row].stopped

      objects[col][row].unlock
      @level -= 1
      @level <= 0
    when :bomb
      ((col - @level)..(col + @level)).each do |i|
        ((row - @level + (col - i).abs)..(row + @level - (col - i).abs)).each do |j|
          next if i < 0 || i >= NUM_COLS || j < 0 || j >= NUM_ROWS

          game.add_bomb_effect(i, j)
          objects[i][j] = nil
        end
      end
      true
    when :line_converter
      (col..(col + @level + 1)).each do |i|
        objects[i][row].type = @arg if objects[i][row].is_a?(Sphere)
      end
      true
    end
  end
end

require 'minigl'
require_relative 'sphere'
require_relative 'lock'

class Item
  def initialize(type, level, arg)
    @type = type
    @level = level
    @arg = arg
    @count = 2 * level if type == :key
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
      return false unless objects[col][row].is_a?(Lock)

      objects[col][row].unlock
      @count -= 1
      @count <= 0
    when :bomb
      ((col - @level)..(col + @level)).each do |i|
        ((row - @level + (col - i).abs)..(row + @level - (col - i).abs)).each do |j|
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

require 'minigl'
require_relative 'constants'

class ItemCursor < MiniGL::Sprite
  def initialize(type, level, arg)
    @type = type
    @level = level
    @arg = arg
    cols = type == :bomb ? 1 : 3
    name = type == :line_converter ? 'lineConverterCursor' : "#{type}Cursor"
    super(0, 0, "interface_#{name}", cols, 1)
  end

  def click(&action)
    if @type == :key
      @action = action
      return
    end

    action.call
  end

  def update
    return unless @type == :key && @action

    animate_once([1, 2, 1, 0], 5) do
      set_animation(0)
      @action.call
      @action = nil
    end
  end

  def draw
    if @type == :line_converter
      @img[0].draw(@x, @y, 0)
      (1..@level).each do |i|
        @img[1].draw(@x + i * SPHERE_SIZE, @y, 0)
      end
      @img[2].draw(@x + (@level + 1) * SPHERE_SIZE, @y, 0)
      Res.img("interface_#{@arg}Sphere").draw(@x + 4, @y + 4, 0)
    else
      super
    end
  end
end

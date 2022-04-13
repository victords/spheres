require 'minigl'

class Sphere < MiniGL::Sprite
  attr_reader :type, :chain
  attr_accessor :stopped, :locked

  def initialize(type, locked, x, y)
    super(x, y, "sprite_#{type}Sphere", 2, 1)
    @type = type
    @locked = locked
    @lock = Res.img(:sprite_cage) if locked
    @chain = 0
  end

  def chain!(value)
    @chain = value
    @stopped = false
  end

  def unchain!
    @chain = 0
  end

  def blink
    animate([0, 1], 5)
  end

  def type=(value)
    @type = value
    @img = Res.imgs("sprite_#{@type}Sphere", 2, 1)
  end

  def draw
    super
    @lock&.draw(@x, @y, 0)
  end
end

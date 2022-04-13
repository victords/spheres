require 'minigl'

class Lock < MiniGL::Sprite
  attr_accessor :stopped

  def initialize(x, y)
    super(x, y, :sprite_lock, 5, 1)
    @locked = true
  end

  def unlock
    @locked = false
  end

  def dead?
    @dead
  end

  def update
    return if @locked

    animate_once([1, 2, 3, 4], 5) do
      @dead = true
    end
  end
end

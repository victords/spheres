require 'minigl'
require_relative 'constants'
require_relative 'game'

include MiniGL

class Window < GameWindow
  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, Game.full_screen)
    self.caption = 'Spheres'
    Res.prefix = File.expand_path(__FILE__).split('/')[0..-3].join('/') + '/data'
    Game.initialize
  end

  def needs_cursor?
    Game.needs_cursor?
  end

  def update
    KB.update
    Mouse.update
    Game.update
  end

  def draw
    Game.draw
  end
end

Game.load
Window.new.show

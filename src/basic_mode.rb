require_relative 'game_mode'

class BasicMode < GameMode
  def initialize
    super

    add_sphere(0, 11, :red)
    add_sphere(1, 11, :green)
    add_sphere(2, 11, :blue)
    add_sphere(3, 11, :cyan)
    add_sphere(4, 11, :magenta)
    add_sphere(5, 11, :yellow)
    add_sphere(6, 11, :rainbow)
    add_sphere(7, 9, :red, true)
    add_sphere(1, 9, :green, true)
    add_sphere(2, 9, :blue, true)
    add_sphere(3, 9, :cyan, true)
    add_sphere(4, 9, :magenta, true)
    add_sphere(5, 9, :yellow, true)
    add_sphere(6, 9, :rainbow, true)
  end
end

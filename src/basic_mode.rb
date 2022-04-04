require_relative 'game_mode'

class BasicMode < GameMode
  def initialize
    super

    add_sphere(0, 0, :red)
    add_sphere(1, 0, :red)
    add_sphere(2, 1, :red)
    add_sphere(3, 2, :red)

    add_sphere(2, 0, :blue)
    add_sphere(3, 0, :blue)
    add_sphere(3, 1, :blue)
    add_sphere(5, 0, :blue)
    add_sphere(2, 2, :blue)

    add_sphere(5, 1, :red)
    add_sphere(6, 0, :red)
    add_sphere(7, 0, :red)
  end
end

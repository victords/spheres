require_relative 'game_mode'

class BasicMode < GameMode
  def initialize
    super

    add_sphere(4, 0, :red)
    add_sphere(4, 1, :red)
    add_sphere(4, 2, :red)
    add_sphere(4, 3, :red)
    add_sphere(4, 4, :red)
    add_sphere(5, 11, :green)
    add_lock(3, 11)
  end
end

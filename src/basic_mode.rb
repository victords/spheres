require_relative 'game_mode'

class BasicMode < GameMode
  def start
    super

    add_sphere(0, 0, :red)
    add_sphere(2, 0, :red)
    add_sphere(3, 0, :red)

    add_sphere(2, 1, :green)
    add_sphere(3, 1, :green)
    add_sphere(4, 0, :green)

    add_sphere(3, 2, :blue)
    add_sphere(4, 1, :blue)
    add_sphere(5, 0, :blue)
  end
end

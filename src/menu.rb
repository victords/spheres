require_relative 'button'

class Menu
  def initialize
    @bg = Res.img(:other_bgStart)

    @buttons = {
      main: [
        Button.new(305, 240, 'Play'),
        Button.new(305, 290, 'Instructions'),
        Button.new(305, 340, 'Options'),
        Button.new(305, 390, 'High Scores'),
        Button.new(305, 480, 'Exit') do
          exit
        end,
      ]
    }

    @state = :main
    Game.play_song(:spheresTheme)
  end

  def update
    @buttons[@state]&.each(&:update)
  end

  def draw
    @bg.draw(0, 0, 0)
    @buttons[@state]&.each(&:draw)
  end
end

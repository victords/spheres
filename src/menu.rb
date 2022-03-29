require_relative 'button'

class Menu
  def initialize
    @bg = Res.img(:other_bgStart)

    @buttons = {
      main: [
        Button.new(305, 240, Localization.text(:play)),
        Button.new(305, 290, Localization.text(:instructions)),
        Button.new(305, 340, Localization.text(:options)),
        Button.new(305, 390, Localization.text(:high_scores)),
        Button.new(305, 480, Localization.text(:exit)) do
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

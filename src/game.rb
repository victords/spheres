require_relative 'menu'

class Game
  class << self
    attr_reader :font

    def initialize
      Locl.initialize
      @music_volume = 10
      @sound_volume = 10
      @font = Res.font(:arialRounded, 24)
      @controller = Menu.new
    end

    def play_song(id)
      song = Res.song(id)
      Gosu::Song.current_song&.stop unless Gosu::Song.current_song == song
      song.volume = @music_volume * 0.1
      song.play(true)
    end

    def play_sound(id)
      Res.sound(id).play(@sound_volume * 0.1)
    end

    def update
      Locl.language = :portuguese if KB.key_pressed?(Gosu::KB_P)
      Locl.language = :spanish if KB.key_pressed?(Gosu::KB_S)

      @controller.update
    end

    def draw
      @controller.draw
    end
  end
end

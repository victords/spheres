require_relative 'menu'

class Game
  class << self
    attr_reader :font, :full_screen, :music_volume, :sound_volume

    def initialize
      Locl.initialize
      @full_screen = false
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

    def change_language(delta)
      index = Locl.languages.index(Locl.language)
      index += delta
      index = 0 if index >= Locl.languages.size
      index = Locl.languages.size - 1 if index < 0
      Locl.language = Locl.languages[index]
    end

    def toggle_full_screen
      G.window.toggle_fullscreen
      @full_screen = !@full_screen
    end

    def change_music_volume(delta)
      @music_volume += delta
      @music_volume = @music_volume.clamp(0, 10)
      Gosu::Song.current_song&.volume = @music_volume * 0.1
    end

    def change_sound_volume(delta)
      @sound_volume += delta
      @sound_volume = @sound_volume.clamp(0, 10)
    end

    def update
      if KB.key_down?(Gosu::KB_LEFT_ALT) && KB.key_pressed?(Gosu::KB_RETURN)
        @full_screen = !@full_screen
      end

      @controller.update
    end

    def draw
      @controller.draw
    end
  end
end

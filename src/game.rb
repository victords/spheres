require 'rbconfig'
require 'fileutils'
require_relative 'menu'
require_relative 'basic_mode'

class Game
  class << self
    attr_reader :font, :text_helper, :full_screen, :music_volume, :sound_volume, :scores

    def load
      @save_dir =
        if /linux/ =~ RbConfig::CONFIG['host_os']
          "#{Dir.home}/.vds-games/spheres"
        else
          "#{Dir.home}/AppData/Local/VDS Games/Spheres"
        end
      FileUtils.mkdir_p(@save_dir) unless File.exist?(@save_dir)

      options_path = "#{@save_dir}/config"
      if File.exist?(options_path)
        File.open(options_path) do |f|
          data = f.read.split(';')
          @full_screen = data[0] == '+'
          @language = data[1].to_i
          @music_volume = data[2].to_i
          @sound_volume = data[3].to_i
        end
      else
        @full_screen = true
        @language = 0
        @music_volume = 10
        @sound_volume = 10
        save_options
      end

      scores_path = "#{@save_dir}/scores"
      if File.exist?(scores_path)
        @scores = []
        File.open(scores_path) do |f|
          modes = f.read.split(';')
          (0..4).each do |i|
            @scores[i] = modes[i].split(',').map { |entry| entry.split(':') }
          end
          @scores[5] = modes[5].to_i
        end
      else
        @scores = [
          [], # basic high scores
          [], # dynamic easy high scores
          [], # dynamic normal high scores
          [], # dynamic hard high scores
          [], # dynamic expert high scores
          1   # static last level reached
        ]
        save_scores
      end
    end

    def initialize
      Locl.initialize
      Locl.language = Locl.languages[@language]
      @language = nil

      @font = Res.font(:arialRounded, 24)
      @text_helper = TextHelper.new(@font)
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

    def save_options
      File.open("#{@save_dir}/config", 'w+') do |f|
        f.write([
          @full_screen ? '+' : '-',
          @language || Locl.languages.index(Locl.language),
          @music_volume,
          @sound_volume
        ].join(';'))
      end
    end

    def save_scores
      File.open("#{@save_dir}/scores", 'w+') do |f|
        f.write(
          "#{@scores[0..4].map { |s| s.map { |e| e.join(':') }.join(',') }.join(';')};#{@scores[5]}"
        )
      end
    end

    def start_basic
      @controller = BasicMode.new
    end

    def start_dynamic(difficulty)
      puts "starting dynamic mode (#{difficulty})"
    end

    def start_static
      puts 'starting static mode'
    end

    def add_score(table_index, rank, name, score)
      @scores[table_index].insert(rank, [name, score])
      @scores[table_index] = @scores[table_index][0...MAX_HIGH_SCORES_ENTRIES]
      save_scores
    end

    def quit
      @controller = Menu.new
    end

    def update
      if KB.key_down?(Gosu::KB_LEFT_ALT) && KB.key_pressed?(Gosu::KB_RETURN)
        @full_screen = !@full_screen
        save_options
      end

      @controller.update
    end

    def needs_cursor?
      @controller.is_a?(GameMode) ? !@controller.game_cursor? : true
    end

    def draw
      @controller.draw
    end
  end
end

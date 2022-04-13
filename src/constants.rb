require 'minigl'

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
TEXT_COLOR = 0x003333

NUM_COLS = 8
NUM_ROWS = 12
SPHERE_SIZE = 40
FALL_SPEED = 2
MATCH_SCORE = [1, 2, 3, 7, 14, 20].freeze
MATCHES_TO_LEVEL_UP_BASE = 2
MATCHES_TO_LEVEL_UP_INCR = 2
SPAWN_INTERVAL_BASE = 180
SPAWN_INTERVAL_DECR = 9
SPAWN_INTERVAL_MIN = 27
ITEM_SCORE_BASE = 3
ITEM_SCORE_INCREASE = 0
ITEM_TYPES = %i[key bomb line_converter].freeze
BASIC_SPHERE_TYPES = %i[red green blue cyan magenta yellow].freeze
MAX_HIGH_SCORES_ENTRIES = 10

Locl = MiniGL::Localization
Vector = MiniGL::Vector

module MiniGL
  class Effect
    def dead?
      @dead
    end
  end
end

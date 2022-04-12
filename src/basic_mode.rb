require_relative 'game_mode'

class BasicMode < GameMode
  def initialize
    super
    @high_scores_table_index = 0
  end

  def start
    super
    @spawn_timer = SPAWN_INTERVAL_BASE - 30
    @spawn_interval = SPAWN_INTERVAL_BASE
    @matches_to_level_up = MATCHES_TO_LEVEL_UP_BASE
  end

  def update
    super
    return if @confirmation || @game_over || @paused

    check_game_over
    return if @game_over

    check_level_up
    @spawn_timer += 1
    return if @spawn_timer < @spawn_interval

    add_sphere(rand(NUM_COLS), NUM_ROWS - 1, BASIC_SPHERE_TYPES.sample, false, true)
    @spawn_timer = 0
  end
end

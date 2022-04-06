require_relative 'game_mode'

class BasicMode < GameMode
  SPHERE_TYPES = %i[red green blue cyan magenta yellow]

  def start
    super
    @spawn_timer = 0
    @spawn_interval = SPAWN_INTERVAL_BASE
    @matches_to_level_up = MATCHES_TO_LEVEL_UP_BASE
  end

  def update
    super
    return if @confirmation

    check_level_up
    @spawn_timer += 1
    if @spawn_timer >= @spawn_interval
      add_sphere(rand(7), NUM_ROWS - 1, SPHERE_TYPES.sample, false, true)
      @spawn_timer = 0
    end
  end
end

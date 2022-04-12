require_relative 'game_mode'

class DynamicMode < GameMode
  def initialize(difficulty)
    @difficulty = difficulty
    super()
    @high_scores_table_index, @thresholds =
      case difficulty
      when :easy   then [1, [1, 2, 3]]
      when :normal then [2, [2, 4, 6]]
      when :hard   then [3, [3, 6, 9]]
      else              [4, [4, 8, 12]]
      end
  end

  def start
    super

    @level, starting_rows = case @difficulty
                            when :easy   then [1, 0]
                            when :normal then [3, 2]
                            when :hard   then [6, 4]
                            else              [10, 6]
                            end
    @matches_to_level_up = MATCHES_TO_LEVEL_UP_BASE + (@level - 1) * MATCHES_TO_LEVEL_UP_INCR
    @spawn_interval = [SPAWN_INTERVAL_BASE - (@level - 1) * SPAWN_INTERVAL_DECR, SPAWN_INTERVAL_MIN].max
    @spawn_timer = @spawn_interval - 30

    (0...starting_rows).each do |j|
      (0...NUM_COLS).each do |i|
        type = BASIC_SPHERE_TYPES.sample
        while i >= 2 && @objects[i - 1][j].type == type && @objects[i - 2][j].type == type ||
          j >= 2 && @objects[i][j - 1].type == type && @objects[i][j - 2].type == type
          type = BASIC_SPHERE_TYPES.sample
        end

        add_sphere(i, j, type)
      end
    end
  end

  def update
    super
    return if @confirmation || @game_over || @paused

    check_game_over
    return if @game_over

    check_level_up
    @spawn_timer += 1
    return if @spawn_timer < @spawn_interval

    col = rand(NUM_COLS)
    row = NUM_ROWS - 1
    r = rand(100)
    if r < @thresholds[0]
      add_lock(col, row)
    elsif r < @thresholds[1]
      add_sphere(col, row, BASIC_SPHERE_TYPES.sample, true, true)
    elsif r < @thresholds[2]
      add_sphere(col, row, :rainbow, false, true)
    else
      add_sphere(col, row, BASIC_SPHERE_TYPES.sample, false, true)
    end

    @spawn_timer = 0
  end
end

class PagesController < ApplicationController

  ENGLISH_WORDS_URL = "https://raw.githubusercontent.com/dwyl/english-words/master/words.txt"
  ENGLISH_WORDS = open(ENGLISH_WORDS_URL).read.tr("\n", " ").split(" ").drop(50)


  SCRABBLE_SCORES = {
    "A" => 1, "B" => 3, "C" => 3, "D" => 2,
    "E" => 1, "F" => 4, "G" => 2, "H" => 4,
    "I" => 1, "J" => 8, "K" => 5, "L" => 1,
    "M" => 3, "N" => 1, "O" => 1, "P" => 3,
    "Q" => 10, "R" => 1, "S" => 1, "T" => 1,
    "U" => 1, "V" => 4, "W" => 4, "X" => 8,
    "Y" => 4, "Z" => 10
  }

  def score
    start_time = Time.at(params[:start_time].to_i)
    grid       = params[:grid].chars
    @attempt    = params[:attempt]
    end_time   = Time.now
    @results   = run_game(@attempt, grid, start_time, end_time)
  end

  def game
    @grid = generate_grid(params[:grid_size].to_i)
    @start_time = Time.now.to_i
  end

  def game_init

  end


  private

  def scrabble_score(word)
    scrabble_score = 0
    word.upcase.each_char { |l| scrabble_score += SCRABBLE_SCORES[l] }
    return scrabble_score
  end

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    letters = []
    SCRABBLE_SCORES.each do |l, x|
      1.upto(120 / x) do
        letters << l
      end
    end
    grid = []
    1.upto(grid_size) { grid << letters.sample }

    return grid
  end

  # Test
  # p generate_grid(6)
  def in_grid?(word, grid)
    grid_h = Hash.new(0)
    r = true
    grid.each { |x| grid_h[x] += 1 }
    word.upcase.chars.each { |l| grid_h[l] > 0 ? grid_h[l] -= 1 : r = false }
    return r
  end

  # Test
  # p g = generate_grid(6)
  # a = gets.chomp.upcase
  # p in_grid?(a, g)

  def english?(word)
    # no gem version:      word.upcase != data_h["output"].upcase
    ENGLISH_WORDS.include?(word.downcase)
  end

  def calculate_score(time_elapsed, word)
    ((scrabble_score(word) / Math.log(time_elapsed + 1)) * 100).to_i
  end

  def message(word, time_elapsed, score, in_grid)
    if !in_grid
      "not in the grid"
    elsif !english?(word)
      "not an english word"
    else
      "well done"
    end
  end

  def return_hash(time_elapsed, score, message)
    {
      time: time_elapsed,
      score: score,
      message: message
    }
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    attempt.upcase!
    time_elapsed = end_time - start_time
    in_grid = in_grid?(attempt, grid)
    score = english?(attempt) && in_grid ? calculate_score(time_elapsed, attempt) : 0
    message = message(attempt, time_elapsed, score, in_grid)
    return_hash(time_elapsed, score, message)
  end
end

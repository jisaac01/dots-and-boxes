BOARDSIZE = 5
DEBUG = true
TIMEOUT = 60 * 4.5

def debug(str, depth=0)
  if DEBUG
    STDERR.puts "#{'  ' * depth}" + str
  end
end

class PerfectPlayer
  attr_accessor :board
  
  def initialize(board)
    self.board = board
  end

  def get_ordered_moves
    three_sided_moves, the_rest = BoardLogic.all_possible_moves(board).partition do
      |move| Square.three_sided?(board.squares[move.row][move.col]) 
    end
    
    two_sided_moves, the_rest = the_rest.partition do |move|
      Square.two_sided?(board.squares[move.row][move.col])
    end
    
    two_side_neighbors, the_rest = the_rest.partition do |move|      
      !two_sided_moves.empty? && two_sided_moves.include?(move.neighbor(board))
    end
    
    [three_sided_moves, the_rest, (two_sided_moves + two_side_neighbors)]
  end
  
  def get_best_move
    three_sided_moves, the_rest, two_sided_moves = get_ordered_moves
    if the_rest.empty? && three_sided_moves.size < 3
      @max_depth = 3
      #debug "three_sided_moves: #{three_sided_moves.size}, the_rest: #{the_rest.size}"
      #debug "initial board: #{board.squares.inspect}"
      #debug board.to_s
      next_move = minimax(true, board.player_id, false, 0)[:move]
    else
      next_move = three_sided_moves.first || the_rest.shuffle.first || two_sided_moves.shuffle.first
    end
    
    next_move.to_s
  end
  
  def minimax(maximize, current_player, streak, depth)
    best_score = maximize ? -10000 : 10000
    best_move = nil

    if (Time.now > $start_time + TIMEOUT) || depth >= @max_depth || BoardLogic.end_state?(board)
      score = BoardLogic.score(board, (streak ? maximize : !maximize)) #because we're scoring for the previous turn
      #debug "End State: depth #{depth}, score: #{score}, maximize: #{(streak ? maximize : !maximize)}", depth
      #debug board.to_s, depth
      best_score = score
    else    
      available_moves = get_ordered_moves.flatten
      #debug "available_moves: #{available_moves.map(&:to_s)}", depth
      available_moves.each_with_index do |move, index|
        #debug "Player #{current_player} current_move: #{move}", depth
        #debug "best_score: #{best_score}, best_move: #{best_move}", depth
        
        new_square_enclosed = board.hypothesize_move(move, current_player)
        #debug "hypothesized_board: #{board.squares.inspect}", depth
        next_player = current_player
        next_maximize = maximize
        streak = true
        
        unless new_square_enclosed # if the player enclosed a square, they get another turn
          next_player = ((current_player == 1) ? 2 : 1)
          next_maximize = !maximize
          streak = false
        end
        
        result = minimax(next_maximize, next_player, streak, depth + 1)
        if maximize
          if (result[:score] > best_score)
            best_score = result[:score]
            best_move = move
          end        
        else
          if (result[:score] < best_score)
            best_score = result[:score]
            best_move = move
          end
        end 
        board.reset_move(move)
      end
    end    

    { :score => best_score, :move => best_move }
  end

end

class Board
  attr_accessor :squares, :player_id, :opponent_id

  def initialize(squares, player_id)
    self.squares = squares
    self.player_id = player_id
    self.opponent_id = player_id == 1 ? 2 : 1
  end

  def to_s
    str = "Player #{player_id}'s board: "

    squares.each_with_index do |row, index|
      if index == 0
        str << "\n#{seperator}#{top_line(row[0])}#{seperator}#{top_line(row[1])}#{seperator}#{top_line(row[2])}#{seperator}#{top_line(row[3])}#{seperator}#{top_line(row[4])}#{seperator}"
      end
      str << "\n #{left_line(row[0])} #{player(row[0])} #{left_line(row[1])} #{player(row[1])} #{left_line(row[2])} #{player(row[2])} #{left_line(row[3])} #{player(row[3])} #{left_line(row[4])} #{player(row[4])} #{right_line(row[4])}"
      str << "\n#{seperator}#{bottom_line(row[0])}#{seperator}#{bottom_line(row[1])}#{seperator}#{bottom_line(row[2])}#{seperator}#{bottom_line(row[3])}#{seperator}#{bottom_line(row[4])}#{seperator}"
    end
    str
  end
  
  def hypothesize_move(move, player, neighbor = false)
    return if move.nil?
    # puts "moving #{move.row} #{move.col} adding side #{move.side}: #{bit_side(move.side)}"
    # puts "before: #{board[move.row][move.col]}"
    new_square_enclosed = false
    # raise "squares[#{move.row}][#{move.col}]: #{squares[move.row][move.col]}" if squares[move.row][move.col].nil?
    # raise " Square.bit_side(#{move.side}) #{Square.bit_side(move.side)}" if Square.bit_side(move.side).nil?

    #debug "squares[#{move.row}][#{move.col}]: #{squares[move.row][move.col]} SIDES[#{move.side}]: #{SIDES[move.side]}", 0
    squares[move.row][move.col] |= SIDES[move.side]
  
    if (squares[move.row][move.col] & 15) == 15
      new_square_enclosed = true
      if player == 2
        squares[move.row][move.col] |= 16
      end
    end
  
    if neighbor #we've already done the other side
      new_square_enclosed
    else
      new_square_enclosed ||= hypothesize_move(move.neighbor(self), player, true)
    end
  end
  
  def reset_move(move, neighbor = false)
    return if move.nil?
    
    squares[move.row][move.col] &= ~SIDES[move.side]
    if (squares[move.row][move.col] & 16) == 16
      squares[move.row][move.col] &= ~16
    end
    
    reset_move(move.neighbor(self), true) unless neighbor
  end

  def player(value)
    if Square.player?(value) 
      Square.player(value)
    else
      ' '
    end
  end
  
  def seperator
    " · "
  end
  
  def top_line(value)
    if Square.top?(value)
      '—' 
    else
      ' '
    end
  end
  
  def bottom_line(value)
    if Square.bottom?(value)
      '—' 
    else
      ' '
    end
  end

  def right_line(value)
    if Square.right?(value)
      '|' 
    else
      ' '
    end
  end

  def left_line(value)
    if Square.left?(value)
      '|' 
    else
      ' '
    end
  end

  def each_square(&block)
    squares.each_with_index do |row, index|
      row.each_with_index do |val, jindex|
        yield index, jindex
      end
    end
  end
  
  def valid_square?(row, col)
    if row < ::BOARDSIZE && row >= 0 &&
      col <= ::BOARDSIZE && col >= 0
      true
    else
      false
    end
  end
  

end

TOP = 1
BOTTOM = 4
RIGHT = 2
LEFT = 8

TOP_BIT = 0
RIGHT_BIT = 1
BOTTOM_BIT = 2
LEFT_BIT = 3

SIDES = {
  TOP_BIT => TOP,
  RIGHT_BIT => RIGHT,
  BOTTOM_BIT => BOTTOM,
  LEFT_BIT => LEFT
}

class Square  
  def self.player?(value)
    player(value)
  end
  
  def self.player(value)
    if value == 15
      1
    elsif value == 31
      2
    end
  end
  
  def self.top?(value)
    (value & TOP) != 0
  end  

  def self.bottom?(value)
    (value & BOTTOM) != 0
  end  

  def self.right?(value)
    (value & RIGHT) != 0
  end  
  
  def self.left?(value)
    (value & LEFT) != 0
  end
  
  # def self.bit_side(side)
  #   # puts "bit_side for #{SIDES[side]}: #{side}"
  #   return TOP_BIT if side == TOP
  #   return RIGHT_BIT if side == RIGHT
  #   return BOTTOM_BIT if side == BOTTOM
  #   return LEFT_BIT if side == LEFT
  # end
  
  def self.open_sides(value)
    sides = []
    sides << TOP_BIT if !top?(value)
    sides << RIGHT_BIT if !right?(value)
    sides << BOTTOM_BIT if !bottom?(value)
    sides << LEFT_BIT if !left?(value)
    sides
  end  
  
  def self.three_sided?(value)
    [7, 11, 13, 14].include? value
  end
  
  def self.two_sided?(value)
    [3, 5, 6, 9, 10, 12].include? value
  end
  
  def self.opposite_side(side)
    case side
    when TOP_BIT
      BOTTOM_BIT
    when BOTTOM_BIT
      TOP_BIT
    when LEFT_BIT
      RIGHT_BIT
    when RIGHT_BIT
      LEFT_BIT
    end
  end 
  
end

class Move
  attr_accessor :row, :col, :side
  
  def initialize(row, col, side)
    self.row = row
    self.col = col
    self.side = side  #0,1,2,3
  end
  
  def to_s
    "#{row} #{col} #{side}"
  end
  
  def neighbor(board)
    move = case side
      when TOP_BIT
        Move.new(row - 1, col, Square.opposite_side(side))
      when BOTTOM_BIT
        Move.new(row + 1, col, Square.opposite_side(side))
      when RIGHT_BIT
        Move.new(row, col + 1, Square.opposite_side(side))
      when LEFT_BIT
        Move.new(row, col - 1, Square.opposite_side(side))
    end
    
    board.valid_square?(move.row, move.col) ? move : nil
  end
  
  def ==(other)
    other && 
    self.row == other.row &&
    self.col == other.col &&
    self.side == other.side
  end
end

# facts about the game board: valid moves, winning state
class BoardLogic

  def self.all_open_squares(board)
    open_squares = []
    board.each_square do |row, column|
      open_squares << [row, column] unless Square.player?(board.squares[row][column])
    end
    open_squares
  end
  
  def self.all_possible_moves(board)
    moves = []
    self.all_open_squares(board).each do |square|
      Square.open_sides(board.squares[square.first][square.last]).each do |side|
        moves << Move.new(square.first, square.last, side)
      end
    end
    moves
  end
  
  def self.end_state?(board)
    all_possible_moves(board).empty?
  end
  
  def self.score(board, maximize)
    player_1_score = player_2_score = 0
    modifier = maximize ? 1 : -1
    board.each_square do |row, column|
      if Square.player(board.squares[row][column]) == 1
        player_1_score += 1
      elsif Square.player(board.squares[row][column]) == 2
        player_2_score += 1
      end
    end
    (player_1_score - player_2_score) * modifier
  end
  
end

class Reader
  def self.read
    input = []
    ::BOARDSIZE.times do 
      row = gets
      input << row
    end
      
    squares = []
    input.size.times do |row|
      squares << input[row].scan(/-?\d+/).map(&:to_i)
    end
    
    player_id = gets.to_i
    if Runner::VERBOSE
      puts "Reader"
      puts "squares: #{squares}"
      puts "player_id: #{player_id}"
    end
    [squares, player_id]
  end
end

class Runner
  VERBOSE = false
  def self.run
    $start_time = Time.now
    squares, player_id = Reader.read
    board = Board.new(squares, player_id)
    board.to_s if VERBOSE
    
    puts PerfectPlayer.new(board).get_best_move
    debug("total time: #{Time.now - $start_time}")
  end
end

Runner.run

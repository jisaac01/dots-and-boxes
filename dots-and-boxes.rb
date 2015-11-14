# class Intelligence
#
#   attr_accessor :game, :board
#
#   def initialize(game)
#     self.game = game
#     self.board = game.board_logic
#   end
#
#   def move
#     next_position = game.possible_moves.shuffle.first
#     "#{next_position.first} #{next_position.last}"
#   end
#
# end


# facts about the game state. Number of exits, relative strengths, pieces being considered for removal
# class Game
#   attr_accessor :board_logic
#
#   def initialize(board_logic)
#     self.board_logic = board_logic
#   end
#
#   def possible_moves
#     board_logic.all_open_squares
#   end
# end


class Board
  attr_accessor :squares, :player_id, :opponent_id

  def initialize(squares, player_id)
    self.squares = squares
    self.player_id = player_id
    self.opponent_id = player_id == 1 ? 2 : 1
  end

  def to_s
    # empty_board =
    #   [['*',' ','*',' ','*',' ','*',' ','*',' ','*',' ','*'], # 0: 2, 1: 4, : 2: 6, 3: 8, 4: 10, 5: 12, 6: 14
    #    [' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '], # 0: 1,3, 1: 3,5 , 2: 5,7, 3: 7,9, 4: 9,11, 5: 11,13, 6: 13,15
    #    ['*',' ','*',' ','*',' ','*',' ','*',' ','*',' ','*'], # 0: 2, 1: 4, : 2: 6, 3: 8, 4: 10, 5: 12, 6: 14
    #    [' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '],
    #    ['*',' ','*',' ','*',' ','*',' ','*',' ','*',' ','*'],
    #    [' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '],
    #    ['*',' ','*',' ','*',' ','*',' ','*',' ','*',' ','*'],
    #    [' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '],
    #    ['*',' ','*',' ','*',' ','*',' ','*',' ','*',' ','*'],
    #    [' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '],
    #    ['*',' ','*',' ','*',' ','*',' ','*',' ','*',' ','*'],
    #    [' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '],
    #    ['*',' ','*',' ','*',' ','*',' ','*',' ','*',' ','*'],
    #   ]
    puts "Player #{player_id}'s board: "
    squares.each_with_index do |row, index|
      if index == 0
        puts "#{seperator}#{top_line(row[0])}#{seperator}#{top_line(row[1])}#{seperator}#{top_line(row[2])}#{seperator}#{top_line(row[3])}#{seperator}#{top_line(row[4])}#{seperator}"
      end
      puts " #{left_line(row[0])} #{player(row[0])} #{left_line(row[1])} #{player(row[1])} #{left_line(row[2])} #{player(row[2])} #{left_line(row[3])} #{player(row[3])} #{left_line(row[4])} #{player(row[4])} #{right_line(row[4])}"
      puts "#{seperator}#{bottom_line(row[0])}#{seperator}#{bottom_line(row[1])}#{seperator}#{bottom_line(row[2])}#{seperator}#{bottom_line(row[3])}#{seperator}#{bottom_line(row[4])}#{seperator}"
    end
  end

  def player(square)
    if square == 15
      '1'
    elsif square == 31
      '2'
    else
      ' '
    end
  end
  
  def seperator
    " · "
  end
  
  def top_line(square)
    if top?(square)
      '—' 
    else
      ' '
    end
  end
  
  def bottom_line(square)
    if bottom?(square)
      '—' 
    else
      ' '
    end
  end

  def right_line(square)
    if right?(square)
      '|' 
    else
      ' '
    end
  end

  def left_line(square)
    if left?(square)
      '|' 
    else
      ' '
    end
  end
    
  def top?(square)
    (square & 1) != 0
  end  

  def bottom?(square)
    (square & 4) != 0
  end  

  def right?(square)
    (square & 2) != 0
  end  
  
  def left?(square)
    (square & 8) != 0
  end

  def each_square(&block)
    squares.each_with_index do |row, index|
      row.each_with_index do |val, jindex|
        yield index, jindex
      end
    end
  end

end

# facts about the game board: valid moves, winning state
# class BoardLogic
#   attr_accessor :board, :player_id, :opponent_id
#
#   def initialize(squares, player_id)
#     self.board = Board.new(squares, player_id)
#   end
#
#   def to_s
#     board.to_s
#   end
#
#   def all_open_squares
#     open_squares = []
#     board.each_square do |row, column|
#       open_squares << [row, column] if board.squares[row][column] == 0
#     end
#     open_squares
#   end
#
#   def square_in_play?(row, column)
#     row <= 2 && row >= 0 &&
#     column <= 2 && column >= 0 &&
#     board[row][column] == 0
#   end
# end

class Reader
  BOARDSIZE = 5
  def self.read
    input = []
    BOARDSIZE.times do 
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
  VERBOSE = true
  def self.run
    squares, player_id = Reader.read
    board = Board.new(squares, player_id)
    board.to_s
    # current_board = BoardLogic.new(squares, player_id)
    # game = Game.new(current_board)
    # ai = Intelligence.new(game)
    # puts ai.move
    # puts current_board.all_open_squares.to_s
    # puts game.possible_moves.shuffle.to_s
  end
end

Runner.run

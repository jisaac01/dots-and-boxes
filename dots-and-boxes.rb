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


# class Board
#   attr_accessor :squares, :player_id, :opponent_id
#
#   def initialize(squares, player_id)
#     self.squares = squares
#     self.player_id = player_id
#     self.opponent_id = player_id == 1 ? 2 : 1
#   end
#
#   def to_s
#     puts "Player #{player_id}'s board: "
#     squares.each do |row|
#       puts " - - - "
#       puts "|#{row.join('|').gsub('0',' ').gsub('1','X').gsub('2','O')}|"
#     end
#       puts " - - - "
#   end
#
#   def each_square(&block)
#     squares.each_with_index do |row, index|
#       row.each_with_index do |val, jindex|
#         yield index, jindex
#       end
#     end
#   end
#
# end

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
    # current_board = BoardLogic.new(squares, player_id)
    # game = Game.new(current_board)
    # ai = Intelligence.new(game)
    # puts ai.move
    # puts current_board.all_open_squares.to_s
    # puts game.possible_moves.shuffle.to_s
  end
end

Runner.run

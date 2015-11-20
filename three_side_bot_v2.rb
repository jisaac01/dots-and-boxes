class PerfectPlayer

  attr_accessor :board
  
  def initialize(board)
    self.board = board
  end

  def move
    three_sided_squares, the_rest = BoardLogic.all_possible_moves(board).partition { |move| Square.three_sided?(board.squares[move.row][move.col]) }
    two_sided_squares, the_rest = BoardLogic.all_possible_moves(board).partition { |move| Square.two_sided?(board.squares[move.row][move.col]) }
    
    random_move = three_sided_squares.first || the_rest.shuffle.first || two_sided_squares.shuffle.first
    "#{random_move.row} #{random_move.col} #{random_move.side}"
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

  def player(square)
    if Square.player?(square) 
      Square.player(square)
    else
      ' '
    end
  end
  
  def seperator
    " · "
  end
  
  def top_line(square)
    if Square.top?(square)
      '—' 
    else
      ' '
    end
  end
  
  def bottom_line(square)
    if Square.bottom?(square)
      '—' 
    else
      ' '
    end
  end

  def right_line(square)
    if Square.right?(square)
      '|' 
    else
      ' '
    end
  end

  def left_line(square)
    if Square.left?(square)
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

end

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
    (value & 1) != 0
  end  

  def self.bottom?(value)
    (value & 4) != 0
  end  

  def self.right?(value)
    (value & 2) != 0
  end  
  
  def self.left?(value)
    (value & 8) != 0
  end
  
  def self.open_sides(value)
    sides = []
    sides << 0 if !top?(value)
    sides << 1 if !right?(value)
    sides << 2 if !bottom?(value)
    sides << 3 if !left?(value)
    sides
  end  
  
  def self.three_sided?(value)
    [7, 11, 13, 14].include? value
  end
  
  def self.two_sided?(value)
    [3, 5, 6, 9, 10, 12].include? value
  end
  
end

class Move
  attr_accessor :row, :col, :side
  
  def initialize(row, col, side)
    self.row = row
    self.col = col
    self.side = side
  end
end

# facts about the game board: valid moves, winning state
class BoardLogic

  def self.all_open_squares(board)
    @open_squares ||= []
    board.each_square do |row, column|
      @open_squares << [row, column] unless Square.player?(board.squares[row][column])
    end
    
    if Runner::VERBOSE
      puts "BoardLogic#all_open_squares"
      puts "squares: #{open_squares}"
    end
    
    @open_squares
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
  
end

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
  VERBOSE = false
  def self.run
    squares, player_id = Reader.read
    board = Board.new(squares, player_id)
    board.to_s if VERBOSE
    
    puts PerfectPlayer.new(board).move
  end
end

Runner.run

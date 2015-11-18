#!/usr/bin/env ruby

require 'open3'
# read both filenames
player_program = []
player_program[1] = ARGV.first
player_program[2] = ARGV.last

class Move
  attr_accessor :row, :col, :side
  
  def initialize(row, col, side)
    self.row = row
    self.col = col
    self.side = side
  end
end

class Board
  BOARD_SIZE = 5
  TOP = 0
  RIGHT = 1
  BOTTOM = 2
  LEFT = 3
  
  SIDES = {
    TOP => :top,
    RIGHT => :right,
    BOTTOM => :bottom,
    LEFT => :left
  }
  
  attr_accessor :board, :valid
  
  def initialize
    self.board = [
     [0, 0, 0, 0, 0],
     [0, 0, 0, 0, 0],
     [0, 0, 0, 0, 0],
     [0, 0, 0, 0, 0],
     [0, 0, 0, 0, 0]
    ]
  end
  
  def to_s
    str = "Current board: "

    board.each_with_index do |row, index|
      if index == 0
        str << "\n#{seperator}#{top_line(row[0])}#{seperator}#{top_line(row[1])}#{seperator}#{top_line(row[2])}#{seperator}#{top_line(row[3])}#{seperator}#{top_line(row[4])}#{seperator}"
      end
      str << "\n #{left_line(row[0])} #{player_indicator(row[0])} #{left_line(row[1])} #{player_indicator(row[1])} #{left_line(row[2])} #{player_indicator(row[2])} #{left_line(row[3])} #{player_indicator(row[3])} #{left_line(row[4])} #{player_indicator(row[4])} #{right_line(row[4])}"
      str << "\n#{seperator}#{bottom_line(row[0])}#{seperator}#{bottom_line(row[1])}#{seperator}#{bottom_line(row[2])}#{seperator}#{bottom_line(row[3])}#{seperator}#{bottom_line(row[4])}#{seperator}"
    end
    puts str
  end
  
  def player_indicator(square)
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
  
  def scores
    player_1_score = 0
    player_2_score = 0
    each_square do |row, column|
      player_1_score += 1 if board[row][column] == 15
      player_2_score += 1 if board[row][column] == 31
    end
    [player_1_score, player_2_score]
  end
      
  def game_result
    player_1_score, player_2_score = scores
    return false unless player_1_score + player_2_score == BOARD_SIZE * BOARD_SIZE
    return :tie if player_1_score == player_2_score
    player_1_score > player_2_score ? :player_1 : :player_2
  end
  
  def tie?
    each_square do |row, column|
      return false if board[row][column] == 0
    end
  end
      
  def each_square(&block)
    board.each_with_index do |row, index|
      row.each_with_index do |val, jindex|
        yield index, jindex
      end
    end    
  end  
  
  def move(move, player_id)
    # puts "moving #{move.row} #{move.col} adding side #{move.side}: #{bit_side(move.side)}"
    # puts "before: #{board[move.row][move.col]}"
    board[move.row][move.col] |= bit_side(move.side)
    
    if (board[move.row][move.col] & 15) == 15 && (player_id == 2)
      board[move.row][move.col] |= 16
    end
    
    move_neighbor(move, player_id)
    # puts "after: #{board[move.row][move.col]}"
  end
  
  def move_neighbor(move, player_id)
    # puts "SIDES[move.side]: #{SIDES[move.side]}"
    move = case SIDES[move.side]
      when :left
        Move.new(move.row, move.col - 1, RIGHT)
      when :right
        Move.new(move.row, move.col + 1, LEFT)
      when :top
        Move.new(move.row - 1, move.col, BOTTOM)
      when :bottom
        Move.new(move.row + 1, move.col, TOP)
    end
    
    if valid_square?(move.row, move.col) && valid_move?(move)
      move(move, player_id)
    end
  end
  
  def valid?(move)    
    if valid_square?(move.row, move.col) &&
      valid_player?(board[move.row][move.col]) &&
      valid_side?(move.side) &&
      valid_move?(move)
      return true
    end
    false
  end
      
  def valid_square?(row, column)
    # puts "valid_square?"
    if row < BOARD_SIZE && row >= 0 &&
      column <= BOARD_SIZE && column >= 0
      true
    else
      self.valid = "not valid coordinates"
      false
    end
  end
  
  def valid_player?(square)
    # puts "valid_player?"
    if Square.player(square).nil?
      true
    else
      self.valid = "not an empty square"
      false
    end
  end
      
  
  def valid_side?(side)
    # puts "valid_side?"
    if (0..3).include? side
      true
    else
      self.valid = "not a valid side"
      false
    end
  end
  
  def valid_move?(move)
    if board[move.row][move.col] != (board[move.row][move.col] | bit_side(move.side))
      # puts "true"
      true
    else
      self.valid = "this move was already made"
      false
    end
  end

  def bit_side(side)
    # puts "bit_side for #{SIDES[side]}: #{side}"
    return 1 if side == TOP
    return 2 if side == RIGHT
    return 4 if side == BOTTOM
    return 8 if side == LEFT
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
end

OUTPUT_SIZE = 3
# create the initial board state
board = Board.new
# output the board to stdout
puts board.to_s

current_player = 1
turn = 1
# while the current player is not surrounded
loop do 
  puts "Turn #{turn}, player #{current_player}"

  # run the file with board + player_id as input
  cmd = "ruby #{player_program[current_player]}"
  move = remove = error = nil
  Open3.popen3(cmd) do |stdin, stdout, stderr|
    board.board.each do |row|
      stdin.puts(row.join(' '))
    end
    stdin.puts(current_player)
    stdin.close
    puts "stdout.gets: #{move = stdout.gets}"
    # puts "stdout.gets: #{random_junk = stdout.gets}"
    # puts "stdout.gets: #{random_junk = stdout.gets}"
    puts "stderr.gets: #{error = stderr.gets}"
  end
  
  # verify that the output is valid

  if (move.empty? || error || move.split(' ').size != OUTPUT_SIZE)
    puts "invalid output #{move}"
    break
  end

  move_array = move.split(' ').map(&:to_i)
  move = Move.new(*move_array)
  # verify that the move is valid
  if board.valid?(move)
    # puts "Before:"
    # puts board.inspect
    board.move(move, current_player)
    # puts "After:"
    # puts board.inspect
  else
  # if board.valid_square(move.first, move.last)
  #   board.board[move.first][move.last] = current_player
  # else
    # puts "invalid move: #{board.valid}"
    break
  end  

  turn = turn + 1
  # output the new board
  puts board.to_s
  current_player = (current_player == 1 ? 2 : 1)
  if result = board.game_result
    puts "Winner: #{result}"
    break 
  end
end


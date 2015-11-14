#!/usr/bin/env ruby

require 'open3'
# read both filenames
player_program = []
player_program[1] = ARGV.first
player_program[2] = ARGV.last

class Board
  attr_accessor :board, :player_1_position, :player_2_position
  def initialize
    self.board = [
     [0, 0, 0],
     [0, 0, 0],
     [0, 0, 0],
    ]
  end
  
  def to_s
    board.each do |row|
      puts " - - - "
      puts "|#{row.join('|').gsub('0',' ').gsub('1','X').gsub('2','O')}|" 
    end
      puts " - - - "
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
  def winner?
    horizontal_winner? ||
    vertical_winner? ||
    diagonal_winner?
  end    
  
  def horizontal_winner?
    board.any? do |row|
      row[0] != 0 && 
      row[0] == row[1] && 
      row[0] == row[2]
    end
  end
  
  def vertical_winner?
    (0..2).any? do |column|
      board[0][column] != 0 && 
      board[0][column] == board[1][column] && 
      board[0][column] == board[2][column]
    end
  end
  
  def diagonal_winner?
    (board[0][0] != 0 &&
    board[0][0] == board[1][1] &&
    board[0][0] == board[2][2]) ||
    (board[2][0] != 0 &&
    board[2][0] == board[1][1] &&
    board[2][0] == board[0][2])
  end
    
  def valid_square(row, column)
    row <= 2 && row >= 0 &&
    column <= 2 && column >= 0 &&
    board[row][column] == 0
  end

end

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
  if (move.empty? || error || move.split(' ').size != 2)
    puts "invalid output #{move}"
    break
  end

  move = move.split(' ').map(&:to_i)
  # verify that the move is valid (on the board, 1 space, etc)
  if board.valid_square(move.first, move.last)
    board.board[move.first][move.last] = current_player
  else
    puts "board.valid_square(move.first, move.last): #{board.valid_square(move.first, move.last)}"
    puts "invalid move #{move.inspect}"
    break
  end  

  turn = turn + 1
  # output the new board
  puts board.to_s
  current_player = (current_player == 1 ? 2 : 1)
  if board.winner?
    current_player = (current_player == 1 ? 2 : 1)
    puts "Player #{current_player} won!"
    break 
  elsif board.tie?
    puts "Tie game :/"
    break
  end
end


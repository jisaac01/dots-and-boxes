require 'test/unit'
require_relative 'stub_runner'
require_relative 'dots-and-boxes'

class ReaderTest < Test::Unit::TestCase

  def test_reader__new
    input_filename = "input_1.txt"
    squares, player_id = read_file(input_filename)

    expected = [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]]
    assert_equal expected, squares
    assert_equal 1, player_id
  end

  def test_reader__some_moves
    input_filename = "input_2.txt"
    squares, player_id = read_file(input_filename)

    expected = [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 2, 8], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]]
    assert_equal expected, squares
    assert_equal 2, player_id
  end

  private

  def read_file(input_filename)
    squares, player_id = nil
    with_stdin do |command_line|
      File.open(input_filename,"r") do |file|
        file.each do |line|
          command_line.puts line
        end
      end

      squares, player_id = Reader.read
    end
    [squares, player_id]
  end

  def with_stdin
    stdin = $stdin             # remember $stdin
    $stdin, write = IO.pipe    # create pipe assigning its "read end" to $stdin
    yield write                # pass pipe's "write end" to block
  ensure
    write.close                # close pipe
    $stdin = stdin             # restore $stdin
  end
end

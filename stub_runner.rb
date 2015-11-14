module Running
  def run
    puts "Run is Stubbed!"
  end
end

class Runner
  VERBOSE=false
  class << self
    prepend Running
  end
end
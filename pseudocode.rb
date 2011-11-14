
class PseudoCodeScript
  
  class Scenario
    def self.default(&b)
      @@default = b
    end
    
    attr_accessor :name, :desc, :block
    def initialize(script, name=nil, desc=nil, &b)
      @script = script
      @name = name
      @desc = desc
      @block = b
    end
    
    def announce()
      out = "\n\r"
      out << "### Running scenario"
      out << " \"#{name}\"" unless name.nil?
      out << " ###"
      out << "\n\r#{desc}" unless desc.nil?
      out << "\n\n\r"
      @script.out_print out
    end

    def call()
      announce()
      @@default.call()
      @block.call()
    end
  end
  
  attr_accessor :pretend_delay, :pretend_output
  
  def initialize()
    super
    @scenarios = []
    @scenario = -1
  end
  
  def on_output(&b)
    @output_block = b
  end
  
  def out_print(str)
    if @output_block.nil?
      print str
    else
      @output_block.call(str)
    end
  end
  
  def out_puts(str)
    out_print(str + "\n\r")
  end
  
  def pretend(msg, delay=nil)
    
    # Set initial values
    @pretend_delay ||= 2
    @pretend_output ||= true
    delay ||= @pretend_delay
    
    out_print msg if @pretend_output
    
    if delay > 0
      (delay*2).times do
        sleep 0.5
        out_print "." if @pretend_output
      end
      #out_puts "Done."
      out_puts "" if @pretend_output
    else
      sleep 0.5
      out_puts "" if @pretend_output
    end
  end
  
  def call(m)
    out_puts "#{self.class}: #{m.to_s.gsub('_',' ')}"
  end

  def default_values(&b)
    Scenario.default(&b)
  end
  
  def add_scenario(*a, &b)
    new_scenario = Scenario.new(self, *a, &b)
    @scenarios << new_scenario
    return new_scenario
  end
  
  def run(*args)
    begin
      credits()
      main(*args)
    rescue Interrupt
      puts "\nInterrupt; closing."
    end
  end
  
  def main
  end
  
  def main_loop
    loop do
      if !@scenarios.empty?
        @scenario += 1
        if @scenario >= @scenarios.size
          if @loop_scenarios
            @scenario = 0
          else
            break
          end
        end
        @scenarios[@scenario].call()
      end
      
      yield
      
    end

    if !@loop_scenarios
      out_puts ""
      out_puts "### All Scenarios complete. ###"
      out_puts ""
    end
  end
  
  def credits()
  end

  #def method_missing?(m)
  #  call(m)
  #end
end


require_relative 'pseudocode.rb'

class Microprocessor < PseudoCodeScript
  def initialize(*a)
    super(*a)
    
    default_values do
      unhook_all()
      @power = :normal
      @temp = :normal
      @footprint_elapsed = false
      @rx = nil
      @downlink_window = 10
      @no_recent_contact = false
    end
    
    add_scenario "normal operation" do
    end
    
    add_scenario "no contact from ground for a while" do
      @no_recent_contact = true
    end
    
    add_scenario "footprint elapsed" do
      @footprint_elapsed = true
    end
    
    add_scenario "transmission cutoff" do
      @rx = :downlink
      @downlink_window = 1
    end
    
    add_scenario "footprint elapsed during transmission" do
      @rx = :downlink
      @downlink_window = 2
      @elapse_during_transmission = true
      
      hook :footprint_elapsed do
        @footprint_elapsed = (@elapse_during_transmission and @downlink_window==1)
      end
    end
    
    add_scenario "transmission completion" do
      @rx = :downlink
      @downlink_window = -1
    end
    
    add_scenario "bad command" do
      @rx = :gibberish
    end
    
    add_scenario "low power" do
      @power = :low
    end
    
    #add_scenario "low temp" do
    #  @temp = :low
    #end
  end
  
  attr_reader :power, :temp
  
  def credits
    out_puts ""
    out_puts "Running Command and Data Handling pseudo code script"
    out_puts "Written by Kristoffer Scott"
    out_puts "2011 ISU Cysat Team"
    out_puts ""
    pretend "", 3
    out_puts ""
  end

  def startup
    pretend "Starting up"
  end
  
  def start_mission_clock
    pretend "Starting mission clock"
  end
  
  def wait_30_minutes
    pretend "Waiting 30 minutes", 3
  end
  
  def allocate_storage_space
    Queue.new(self, "Data storage")
  end
  
  def check_power
    pretend "Checking power"
  end
  
  def power_is_low
    if (@power == :low)
      pretend "Power is low!", 0
      return true
    else
      pretend "There is enough power.", 0
      return false
    end
  end
  
  def wait_low_power
    pretend "Waiting in low-power state", 3
  end
  
  def no_recent_contact
    if !@rx.nil?
      @no_recent_contact = false
    end
    if @no_recent_contact
      pretend "Contact has not been established recently."
    end
    return @no_recent_contact
  end
  
  def transmit_beacon_signal
    pretend "Transmitting beacon signal", 3
  end
  
  def footprint_elapsed
    if @footprint_elapsed
      pretend "Payload footprint distance has been traveled.", 0
      return true
    else
      pretend "Payload footprint distance has not yet been traveled.", 0
      return false
    end
  end
  
  def turn_on_radiometer(i)
    pretend "Turning on radiometer #{i}", 1
  end
  
  def turn_off_radiometer(i)
    pretend "Turning off radiometer #{i}", 1
  end
  
  def collect_radiometer_data(i)
    pretend "Collecting data from radiometer #{i}"
    d = "rad#{i}data#{Time.now.to_i}"
    pretend "Radiometer #{i} sent: #{d}", 0
    return d
  end
  
  def timestamp
    "timestamp#{Time.now.to_i}"
  end
  
  def get_eps_data
    pretend "Collecting EPS data"
    d = "#{@power} #{@temp} #{Time.now.to_i}"
    pretend "EPS sent: \"#{d}\"", 0
    return d
  end
  
  def message_received
    if @rx.nil?
      pretend "No messages from ground.", 0
      return false
    else
      pretend "Message received from ground", 0
      return true
    end
  end
  
  def interpret_message
    pretend "Interpreting message"
    pretend "Parsed message from ground: \"#{@rx}\"", 0
    return @rx
  end
  
  def pause_transmission()
    pretend "There is an interruption. Pausing transmission.", 0
  end
  
  def resume_transmission()
    pretend "Resuming transmission.", 0
  end
  
  def transmission_loop
    pretend "Preparing to transmit"
    @transmitting = true
    loop do
      yield
    end
  end
  
  def end_transmission
    pretend "Stopping transmission"
    @transmitting = false
  end
  
  def send_message(msg)
    pretend "Sending message: \"#{msg}\""
    @last_msg = msg
  end
  
  def transmission_acknowledged
    if @downlink_window != 0
      pretend "Ground acknowledged.", 0
      @downlink_window -= 1
    else
      pretend "Ground did not acknowledge.", 0
    end
  end
  
  def send_unknown_command_error
    pretend "Replying with 'Unknown command error'"
  end
end

class Queue
  def initialize(parent, name = nil)
    super()
    @parent = parent
    @name = name || "#{self.class}"
    @parent.pretend "Allocating storage for #{@name}"
    @array = Array.new
  end
  
  def push(data)
    @parent.pretend "Storing data \"#{data}\"", 1
    @array.push data
  end
  
  def first()
    @parent.pretend "Loading data \"#{@array.first}\"", 1
    @array.first
  end
  
  def shift()
    @parent.pretend "Deleting data \"#{@array.first}\"", 1
    @array.shift
  end
  
  def empty?()
    if @array.empty?
      @parent.pretend "#{@name} is empty.", 0
    else
      @parent.pretend "#{@name} has data.", 0
    end
    return @array.empty?
  end
  
  def clear()
    @parent.pretend "Deleting all data from #{@name}"
    @array.clear
  end
end

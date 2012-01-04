# Command and Data Handling Pseudocode
require_relative 'microprocessor.rb'

class Microprocessor
  
  # Collecting data function
  def collect_payload_data()
    # Store timestamp
    @data.push timestamp
    
    # Collect data from each radiometer
    3.times do |i|
      turn_on_radiometer(i)
      @data.push collect_radiometer_data(i)
      turn_off_radiometer(i)
    end
    
    # Store EPS data
    @data.push get_eps_data
  end
  
  # Transmitting data function
  def transmit_data()
  
    # Loop until broken
    transmission_loop do
    
      # End loop if no more data to transmit
      if @data.empty?
        break
      end
      # Payload has highest priority, so if collect payload data if needed
      if footprint_elapsed
        pause_transmission
        collect_payload_data()
        resume_transmission
      end
      
      # Send next data packet
      send_message @data.first
      
      # Check if ground has acknowledged message (Are we still in range?)
      if transmission_acknowledged
        # Delete data
        @data.shift
      else
        # Keep message, stop transmitting.
        break
      end
    end
    
    end_transmission
  end
  
  # Main function (start here)
  def main(*args)
    # Initialization
    
    startup
    start_mission_clock
    
    @data = allocate_storage_space
    
    wait_30_minutes
    
    # Main loop
    main_loop do
      check_power
      if power_is_low
        wait_low_power
      elsif no_recent_contact
        transmit_beacon_signal
      elsif footprint_elapsed
        collect_payload_data()
      elsif message_received
        case interpret_message
          
          # When Ground sends command "downlink":
          when :downlink 
            transmit_data()
            
          # When Ground sends a command that we don't understand
          else
            send_unknown_command_error
          
        end
        
      else
        wait_low_power
      end
    end
  end
end

if $0 == __FILE__
  up = Microprocessor.new
  up.delay_off
  up.run
end

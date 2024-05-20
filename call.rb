# Call class, this is the parent class containing its initialize function, cost function is delegated to its subclasses

class Call
    attr_reader :call_length, :start_time, :end_time
  
    def initialize(start_time, end_time)
      @start_time = start_time
      @end_time = end_time
      @call_length = ((end_time - start_time) * 24 * 60).to_i # Calculate duration in minutes
    end
  end
  
  # Subclass from Local Calls 
  class LocalCall < Call
    def cost
      total_cost = 0.0
      current_time = @start_time
  
      while current_time < @end_time
        day = current_time.wday
        hour = current_time.hour
  
        if (1..5).include?(day) # Weekdays (Monday to Friday)
          if (8..19).include?(hour) # Peak hours
            rate = 0.20
          else # Off-peak hours
            rate = 0.10
          end
        else # Saturdays and Sundays
          rate = 0.10
        end
  
        # Checks if we are closer to the next hour or if the end time is in this hour (second option only will happen in last iteration)
        next_hour = DateTime.new(current_time.year, current_time.month, current_time.day, current_time.hour + 1)
        duration = [(next_hour - current_time) * 24 * 60, (@end_time - current_time) * 24 * 60].min
  
        # Add to total cost hour by hour so as to be precise in which rate should apply in each case
        total_cost += duration * rate
  
        current_time = next_hour
      end
  
      total_cost
    end
  end
  
  # Subclass from Domestic Calls 
  class DomesticCall < Call
    def initialize(start_time, end_time, domestic_cost)
      super(start_time, end_time)
      @cost_per_minute = domestic_cost
    end
  
    def cost
      @call_length * @cost_per_minute
    end
  end
  
  # Subclass from International Calls 
  class InternationalCall < Call
    def initialize(start_time, end_time, international_cost)
      super(start_time, end_time)
      @cost_per_minute = international_cost
    end
  
    def cost
      @call_length * @cost_per_minute
    end
  end
  
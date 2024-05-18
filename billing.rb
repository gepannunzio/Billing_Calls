require 'date'

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

# Bill class, in charge of grab data from DB and delegate funcionalities like cost calculation to Call classes
class Bill
  def initialize(standard_rate, international_cost, domestic_cost)
    @standard_rate = standard_rate
    @international_cost = international_cost
    @domestic_cost = domestic_cost
    @calls = [] # Full list of class
    @local_calls = [] # call filtered ( same international code and area code)
    @international_calls = [] # calls filtered (different international code)
    @domestic_calls = [] # calls filtered (same international code, same area code)

    @local_calls_total = 0
    @domestic_calls_total = 0
    @international_calls_total = 0
  end

  def add_call(call)
    @calls << call
  end

  def get_call_length(start_date, end_date)
    ((end_date - start_date) * 24 * 60).to_i #Difference in dates in minutes
  end

  def get_total(month)
    @calls.each do |call|
      if call[:start_full_date].month == month #Checks if call was in desired month
        if call[:origin_country_code] == call[:dest_country_code] # Compare country code
          if call[:origin_area_code] == call[:dest_area_code] # Compare area code
            current_call = LocalCall.new(call[:start_full_date], call[:end_full_date])
            cost = current_call.cost
            @local_calls_total += cost
            @local_calls << ["Source: " << call[:origin_country_code] << "-" << call[:origin_area_code] << "-" << call[:origin_number] << "  " << "Destination: " << call[:dest_country_code] << "-" << call[:dest_area_code] << "-" << call[:dest_number] << "  " << "$#{'%.2f' % cost}" ]
          else
            current_call = DomesticCall.new(call[:start_full_date], call[:end_full_date], @domestic_cost[call[:dest_area_code]])
            cost = current_call.cost
            @domestic_calls_total += current_call.cost
            @domestic_calls << ["Source: " << call[:origin_country_code] << "-" << call[:origin_area_code] << "-" << call[:origin_number] << "  " << "Destination: " << call[:dest_country_code] << "-" << call[:dest_area_code] << "-" << call[:dest_number] << "  " << "$#{'%.2f' % cost}" ]
          end
        else
          current_call = InternationalCall.new(call[:start_full_date], call[:end_full_date], @international_cost[call[:dest_country_code]])
          cost = current_call.cost
          @international_calls_total += current_call.cost
          @international_calls << ["Source: " << call[:origin_country_code] << "-" << call[:origin_area_code] << "-" << call[:origin_number] << "  " << "Destination: " << call[:dest_country_code] << "-" << call[:dest_area_code] << "-" << call[:dest_number] << "  " << "$#{'%.2f' % cost}" ]
        end
      end
    end
    @local_calls_total + @domestic_calls_total + @international_calls_total + @standard_rate # Get grand total
  end

  def get_details
    puts "Standard Rate: "
    puts "$#{'%.2f' % @standard_rate}"
    puts "Local Calls: "
    puts @local_calls 
    puts "Total Local: $#{'%.2f' % @local_calls_total}"
    puts "Domestic Calls: "
    puts @domestic_calls
    puts "Total Domestic: $#{'%.2f' % @domestic_calls_total}"
    puts "International Calls: "
    puts @international_calls
    puts "Total International: $#{'%.2f' % @international_calls_total}"
  end
end

# Get Costs from DB (assuming this is internal DB, I assume the data is diggested priorly)
# It would be good to have prior knowledge of what type of object we are working as to minimize 
# Class validation. In this case I will asume I dont count with that information

#I assume I will have a complete list with all country and area codes related with their particular 
#costs for a client residing one specific country. 
# If I could count with specific information on all countries costs and their local costs I could expand this further
standard_rate =  30.0
domestic_cost_US = {
  "606"=> 0.3,
  "204"=> 0.5
}
international_cost_US = {
  "55" => 2.0,
  "54"=> 3.0
}

# To expand this to multiple countries assuming every area have a fix cost regardless the origin of the call inside that same country
# I should dispose from a Hash table that for each country has a new Hash for the areas as keys and costs as values. All this is DB related hence I will not be implementing it
# I will keep it simple having a fixed country for my client assuming every area has a fixed cost

example1 = {
  origin_country_code: "1",
  origin_area_code: "204",
  origin_number: "1113698",
  dest_country_code: "1",
  dest_area_code: "204",
  dest_number: "9052034",
  start_full_date: DateTime.new(2024, 5, 13, 9, 0, 0),
  end_full_date: DateTime.new(2024, 5, 13, 9, 10, 0) # 10 minutes
}

example2 = {
  origin_country_code: "1",
  origin_area_code: "606",
  origin_number: "1113537",
  dest_country_code: "1",
  dest_area_code: "204",
  dest_number: "9052034",
  start_full_date: DateTime.new(2024, 5, 13, 21, 20, 0),
  end_full_date: DateTime.new(2024, 5, 13, 21, 40, 0) # 20 minutes
}

example3 = {
  origin_country_code: "1",
  origin_area_code: "606",
  origin_number: "1113537",
  dest_country_code: "54",
  dest_area_code: "11",
  dest_number: "5808909",
  start_full_date: DateTime.new(2024, 5, 18, 14, 0, 0),
  end_full_date: DateTime.new(2024, 5, 18, 14, 15, 0) # 15 minutes
}

example4 = {
  origin_country_code: "1",
  origin_area_code: "606",
  origin_number: "1113537",
  dest_country_code: "54",
  dest_area_code: "11",
  dest_number: "5808909",
  start_full_date: DateTime.new(2024, 3, 18, 14, 0, 0),
  end_full_date: DateTime.new(2024, 3, 18, 14, 15, 0) # 15 minutes
}

# Grouping calls taken from DB in one array for better management

details = [example1, example2, example3, example4]

# Create the bill object and adding the call taken from DB
bill = Bill.new(standard_rate, international_cost_US, domestic_cost_US)

details.each do |call|
  bill.add_call(call)
end

# Choose month to calculate costs (examples are for month 5 and 3)
puts("Select Month Number to Calculate: ")
month = gets.to_i

# Calculate the total bill for May (month 5)
total = bill.get_total(month)
puts " "

#Give detailed breakdown on bill
puts "Month to liquidate: #{'%i' % month}"
details = bill.get_details
puts "Total de la factura: $#{'%.2f' % total}"

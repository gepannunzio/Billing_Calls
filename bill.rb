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
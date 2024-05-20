require 'date'
require_relative 'call'
require_relative 'bill'

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

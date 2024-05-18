require 'date'

class Client
  attr_reader :country, :area

  def initialize(country, area)
    @country = country
    @area = area
  end

end

class Call
  attr_reader :call_lenght, :day_hour, :number_called

  def initialize(call_lenght,day_hour)    
      @call_lenght = call_lenght
      @day_hour = day_hour
  end

end

class LocalCall < Call
  def cost
    day = @day_hour.wday
    hour = @day_hour.hour
    if (1..5).include?(day) # Días hábiles (lunes a viernes)
      if (8..19).include?(hour)  # Franja cara
        @call_lenght * 0.20
      else  # Franja barata
        @call_lenght * 0.10
      end
    else  # Sábados y domingos
      @call_lenght * 0.10
    end
  end
end

# Clase para las llamadas nacionales
class DomesticCall < Call
  def initialize(call_lenght, day_hour, domestic_cost)
    super(call_lenght, day_hour)
    @cost_per_minute = domestic_cost
  end

  def cost
    @call_lenght * @cost_per_minute
  end
end

# Clase para las llamadas internacionales
class InternationalCall < Call
  def initialize(call_lenght, day_hour, international_cost)
    super(call_lenght, day_hour)
    @cost_per_minute = international_cost
  end

  def cost
    @call_lenght * @cost_per_minute
  end
end

# Clase para la factura mensual
class Bill
  def initialize(standard_rate)
    @standard_rate = standard_rate
    @calls = []
  end

  def add_call(call)
    @calls << call
  end

  def get_total
    total = @standard_rate
    @calls.each do |call|
      total += call.cost
    end
    total
  end
end

def get_call_length(start_date, end_date)
  res = ((end_date - start_date) * 24 * 60 * 60).to_i
  res = res/60
  res
end


#Get From DB (I will suppose that this is my internal DB, where I have every country code and the Standard Rate)
standard_rate = 30.0
domestic_cost = 0.5
international_cost = 2.0
country = { "54" => "Arg", "1" => "Us", "55" => "Br" }

# Crear la factura
bill = Bill.new(standard_rate)

# I assume that I will be receiving data with the following format [orgin_number, dest_number, start_full_date, end_full_date]
# I will assume that I have a parser function that is able to retrieve country code from a number, it should consist of purifing the number and converting it to string, expecting it to be received in a specific format
# After the parsing, the final input will be in the following format
# {origin_country_code, origin_area_code, origin_number, dest_country_code, dest_area_code, dest_number, start_full_date, end_full_date]}
example1 = {"origin_country_code" => "1", "origin_area_code" => "606", "origin_number" => "1113537", "dest_country_code" => "1", "dest_area_code" => "204", "dest_number" => "9052034","start_full_date" => DateTime.new(2024, 5, 13, 9, 0, 0), "end_full_date" => DateTime.new(2024, 5, 13, 9, 10, 0)}
example2 = {"origin_country_code" => "54", "origin_area_code" => "606", "origin_number" => "1113537", "dest_country_code" => "1", "dest_area_code" => "204", "dest_number" => "9052034","start_full_date" => DateTime.new(2024, 5, 13, 21, 0, 0), "end_full_date" => DateTime.new(2024, 5, 13, 21, 20, 0)}
example3 = {"origin_country_code" => "1", "origin_area_code" => "606", "origin_number" => "1113537", "dest_country_code" => "1", "dest_area_code" => "606", "dest_number" => "7778909","start_full_date" => DateTime.new(2024, 5, 18, 14, 0, 0), "end_full_date" => DateTime.new(2024, 5, 18, 14, 15, 0)}

details = [example1,example2,example3]

for i in (0...details.length)
  if (details[i]["end_full_date"].month == Date.today.month)
    if (details[i]["origin_country_code"] == details[i]["dest_country_code"]) 
      if (details[i]["origin_area_code"] == details[i]["dest_area_code"])
        bill.add_call(LocalCall.new(get_call_length(details[i]["start_full_date"], details[i]["end_full_date"]), details[i]["start_full_date"]))
      else
        bill.add_call(DomesticCall.new(get_call_length(details[i]["start_full_date"], details[i]["end_full_date"]), details[i]["start_full_date"], domestic_cost))
      end
    else
      bill.add_call(InternationalCall.new(get_call_length(details[i]["start_full_date"], details[i]["end_full_date"]), details[i]["start_full_date"], international_cost))
    end
  end
end
# Calcular el total de la factura
total = bill.get_total
puts "Total de la factura: $#{'%.2f' % total}"


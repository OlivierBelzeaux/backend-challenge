require 'json'
require 'date'
file = File.read("data/input.json")
data = JSON.parse(file)

cars = data['cars']
all_rentals = data['rentals']
rentals = Hash.new { |h,k| h[k] = [] }

def discount_amount(price_per_day, reduced_days)
  amount = 0
 if reduced_days.count > 1 && reduced_days.count <= 4
   amount = amount + ((price_per_day * 0.10) * reduced_days[1..-1].count )
 elsif reduced_days.count > 4 && reduced_days.count <= 10
  amount = amount + ((price_per_day * 0.30) * reduced_days[5..-1].count )
 elsif reduced_days.count >= 11
  amount = amount + (((price_per_day * 0.50) * reduced_days[10..-1].count) + ((price_per_day * 0.30) * reduced_days[4..9].count) + ((price_per_day * 0.10) * reduced_days[1..3].count)  )
 else
   return amount
 end
 return amount.to_i
end

all_rentals.each_with_index do |rental, index|
  id_car = rental['car_id']
  car = cars[id_car - 1]
  distance = rental['distance']
  price_per_km = car['price_per_km']
  price_per_day = car['price_per_day']
  rental_days = 1 + ((DateTime.parse(rental['end_date'])).yday - (DateTime.parse(rental['start_date'])).yday)
  reduced_days = Array.new(rental_days)
  price = ((price_per_km * distance) + ((rental_days) * price_per_day))
  reduced_price = price - (discount_amount(price_per_day, reduced_days))

  rentals["rentals"] << ({"id": (index + 1), "price": reduced_price})
end



File.open("data/output.json", "wb") do |file|
  file.write(JSON.generate(rentals))
end

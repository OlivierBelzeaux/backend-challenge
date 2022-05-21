require 'json'
require 'date'
file = File.read("data/input.json")
data = JSON.parse(file)

cars = data['cars']
all_rentals = data['rentals']
rentals = Hash.new { |h,k| h[k] = [] }

all_rentals.each_with_index do |rental, index|
  id_car = rental['car_id']
  car = cars[id_car - 1]
  distance = rental['distance']
  price_per_km = car['price_per_km']
  price_per_day = car['price_per_day']
  rental_days = 1 + ((DateTime.parse(rental['end_date'])).yday - (DateTime.parse(rental['start_date'])).yday)
  price = (price_per_km * distance) + ((rental_days) * price_per_day)

  rentals["rentals"] << ({"id": (index + 1), "price": price})
end

File.open("data/output.json", "wb") do |file|
  file.write(JSON.generate(rentals))
end

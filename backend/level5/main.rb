require 'json'
require 'date'
file = File.read("data/input.json")
data = JSON.parse(file)

all_cars = data['cars']
all_rentals = data['rentals']
all_options = data['options']
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
 return amount
end

def calcul_price(price_per_km, price_per_day, distance, rental_days)
  price = (price_per_km * distance) + ((rental_days) * price_per_day)
  return price
end

def calcul_rental_days(start_date, end_date)
  rental_days = 1 + ((DateTime.parse(end_date)).yday - (DateTime.parse(start_date)).yday)
  return rental_days
end

def amount_for_insurance(price)
  amount_of_insurance = (price * 0.3) * 0.5
  return amount_of_insurance
end

def amount_for_roadside_assistance(price, days)
  amount_of_roadside_assistance = price * days
  return amount_of_roadside_assistance
end

def amount_for_drivy(reduced_price, insurance_fee, assistance_fee, taux)
  amount_for_drivy = ((reduced_price * taux) - (insurance_fee + assistance_fee))
  return amount_for_drivy
end

def set_reduced_days(rental_days)
  Array.new(rental_days)
end

def set_rental_output(index, reduced_price, insurance_fee, assistance_fee, drivy_fee, taux, options)
({"id": (index + 1),
  "options": options,
   "actions": [
    {
      "who": "driver",
      "type": "debit",
      "amount": reduced_price.to_i
    },
    {
      "who": "owner",
      "type": "debit",
      "amount": (reduced_price - (reduced_price * taux)).to_i
    },
    {
      "who": "insurance",
      "type": "debit",
      "amount": insurance_fee.to_i
    },
    {
      "who": "assistance",
      "type": "credit",
      "amount": assistance_fee.to_i
    },
    {
      "who": "drivy",
      "type": "credit",
      "amount": drivy_fee.to_i
    }
  ]})
end

def set_options(rental_id, options)
  list_of_options = []
  options.each do |option|
    if option['rental_id'] == rental_id
      list_of_options << option['type']
    end
  end
  return list_of_options
end

all_rentals.each_with_index do |rental, index|
  rental_id = rental['id']
  car_id = rental['car_id']
  car = all_cars[car_id - 1]
  distance = rental['distance']
  price_per_km = car['price_per_km']
  price_per_day = car['price_per_day']
  option = all_options[rental_id - 1]
  option_id = option['rental_id']

  options = set_options(rental_id, all_options)

  rental_days = calcul_rental_days( rental['start_date'], rental['end_date'])
  reduced_days = set_reduced_days(rental_days)
  price = calcul_price(price_per_km, price_per_day, distance, rental_days)
  reduced_price = price - (discount_amount(price_per_day, reduced_days))

  insurance_fee = amount_for_insurance(reduced_price)
  assistance_fee = amount_for_roadside_assistance(100, rental_days)
  drivy_fee = amount_for_drivy(reduced_price, insurance_fee, assistance_fee, 0.3)

  rentals["rentals"] << set_rental_output(index, reduced_price, insurance_fee, assistance_fee, drivy_fee, 0.3, options)
end



File.open("data/output.json", "wb") do |file|
  file.write(JSON.generate(rentals))
end

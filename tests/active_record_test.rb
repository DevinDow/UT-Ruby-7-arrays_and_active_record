require "test/unit"
require 'ffaker'

require_relative "../support/active_record_support"

def create_car(options = {})
  options[:color]     ||=  Car::COLOR_ARRAY.sample
  options[:condition] ||=  Car::CONDITION_ARRAY.sample
  options[:top_speed] ||=  Car::SPEEDS_ARRAY.sample

  Car.create(:color     => options[:color],
             :condition => options[:condition],
             :top_speed => options[:top_speed])
end



class ActiveRecordTest < Test::Unit::TestCase

  # Use where method assign variable to a dealership with the same name "Fake Name"
  # assign to variable `dealership`
  def test_regular_where
    puts 'Test = test_regular_where---------------------------------------------------------'

    dealership = nil

    name = FFaker::Company.name
    puts 'Company.name = ' + name
    d    = Dealership.create(:name => name)

    dealership = Dealership.where(:name => name).first

    assert_equal d, dealership
  end


  # Group and count all the cars with the color "cheetah"
  # use the group and count methods, assign your output to the variable `color_group`
  # use the `group` & `count` methods
  # assign to variable `color_group`
  def test_select
    puts 'Test = test_select---------------------------------------------------------'

    color_group = {}

    cars = []
    3.times do
      cars << Car.create(:color => "cheetah")
    end

    color_group = Car.group(:color).count
    puts color_group

    assert_equal Car.where(:color => "cheetah").count, color_group["cheetah"]
  end

  # Use the `LIKE` operator in SQL to find all cars with conditions that contain "good"
  # assign to `your_cars` variable
  def test_like
    puts 'Test = test_like---------------------------------------------------------'

    your_cars = []

    cars = []
    cars << Car.create(:condition => "goodish")
    cars << Car.create(:condition => "very good")
    cars << Car.create(:condition => "not so good")
    Car.create(:condition => "straight up bad")
    puts 'cars = '
    cars.each { |car| puts car.inspect }

    your_cars = Car.where("condition LIKE '%good%'").all
    puts 'your_cars = '
    your_cars.each { |car| puts car.inspect }

    assert_equal cars, your_cars

    Car.delete_all
  end


  # find all the dealerships with given id's use the IN keyword in SQL
  # you can drop to SQL in a where using (?) syntax : ('something = (?)', variable)
  # the variable of `ids` holds an array of all of the dealership's id's
  # assign to variable dealerships
  def test_in
    puts 'Test = test_in---------------------------------------------------------'

    dealerships = nil

    dealerz = 3.times.map { Dealership.create(:name => FFaker::Company.name) }
    puts 'dealerz = '
    dealerz.each { |dealer| puts dealer.inspect }

    ids     = dealerz.map {|d| d.id }
    dealerships = Dealership.where("id in (?)", ids)
    puts 'dealerships = '
    dealerships.each { |dealer| puts dealer.inspect }

    assert_equal dealerz, dealerships

  end


  # Find all the cars of a given color in reverse order by created_at using the `order()` method
  # remember time is ever increasing in a positive direction, how do you want to order ASC or DESC?
  # assign to a variable reverse_cars
  def test_order
    puts 'Test = test_order---------------------------------------------------------'

    reverse_cars = []

    cars = 5.times.map { sleep(0.001); Car.create }
    puts 'cars = '
    cars.each { |car| puts car.inspect }

    puts 'cars.reverse = '
    cars.reverse.each { |car| puts car.inspect }
    reverse_cars = Car.order("created_at DESC").all
    puts 'reverse_cars = '
    reverse_cars.each { |car| puts car.inspect; puts car.created_at.to_f }
    if cars.reverse == reverse_cars
      puts "equal"
    else
      puts "not equal"
    end

    assert_equal cars.reverse, reverse_cars

    Car.delete_all
  end


  # find the first 4 cars
  # assign to variable `limited_cars`
  def test_limit
    puts 'Test = test_limit---------------------------------------------------------'

    limited_cars = nil

    puts 'cars = '
    cars = 5.times.map { Car.create }
    cars.each { |car| puts car.inspect }
    
    limited_cars = Car.first(4)
    puts 'limited_cars = '
    limited_cars.each { |car| puts car.inspect }
    
    assert_equal cars.first(4), limited_cars
    
    Car.delete_all
  end

  # find the second and third cars, using offset and limit methods
  # assign to variable `offset_cars`
  def test_offset
    puts 'Test = test_offset---------------------------------------------------------'

    offset_cars = nil

    cars = 5.times.map {Car.create}
    puts 'cars = '
    cars.each { |car| puts car.inspect }

    offset_cars = Car.offset(1).limit(2)
    puts 'offset_cars = '
    offset_cars.each { |car| puts car.inspect }

    assert_equal cars[1,2], offset_cars
    
    Car.delete_all
  end



  # Find all dealerships that have a car colored "red", assign to a variable dealerships
  # use joins
  # assign to variable `dealerships`
  def test_joins
    puts 'Test = test_joins---------------------------------------------------------'

    dealerships = nil

    dealerz = []
    3.times do
      d = Dealership.create(:name => FFaker::Company.name)
      d.cars.create(:color => "red")
      dealerz << d
    end
    d = Dealership.create(:name => FFaker::Company.name)
    d.cars.create(:color => "blue")
    puts 'dealerz = '
    dealerz.each { |dealer| puts dealer.inspect; dealer.cars.each { |car| puts car.inspect } }

    dealerships = Dealership.joins(:cars).where(:cars => {:color => "red"}).all
    puts 'dealerships = '
    dealerships.each { |dealer| puts dealer.inspect; dealer.cars.each { |car| puts car.inspect } }

    assert_equal dealerz, dealerships
  end


  # Use the #having operator to find all the dealerships that have cars of an average top speed of 5 or more
  # to get you started the join and group statements are included below, just
  # fill out the having statement
  # use AVG() function in SQL to average values
  # use >= for a greater than or equal comparison
  # assign to variable `dealerships`
  def test_having
    puts 'Test = test_having---------------------------------------------------------'

    dealerships = []

    dealerz = []
    color = "liger yellow"
    3.times do
      d = Dealership.create(:name => FFaker::Company.name)
      d.cars.create(:color => color, :top_speed => 5)
      dealerz << d
    end
    d  = Dealership.create(:name => FFaker::Company.name)
    d.cars.create(:color => color, :top_speed => 2)
    puts 'dealerz = '
    dealerz.each { |dealer| puts dealer.inspect; dealer.cars.each { |car| puts car.inspect } }

    dealerships = Dealership.joins(:cars).group("dealerships.id, cars.top_speed").having("AVG(cars.top_speed) >= 5")
    puts 'dealerships = '
    dealerships.each { |dealer| puts dealer.inspect; dealer.cars.each { |car| puts car.inspect } }
    
    assert_equal dealerz, dealerships.all
  end

end

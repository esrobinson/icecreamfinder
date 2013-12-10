require 'addressable/uri'
require 'rest-client'
require 'json'
require 'nokogiri'

class IceCreamFinder

  KEY = 'AIzaSyAQfQlXnYhu2JVO9dYDaD712xRKz-0HQcM'

  def get_address
    puts "Please enter your address."
    gets.chomp
  end

  def coordinates(address)
    url = Addressable::URI.new(
    :scheme => "http",
    :host => "maps.googleapis.com",
    :path => "maps/api/geocode/json",
    :query_values => { :address => address, :sensor => false }
    )
    response = RestClient.get(url.to_s)
    JSON.parse(response)["results"].first["geometry"]["location"]
  end

  def find_ice_cream(coordinates)
    lat = coordinates['lat']
    lng = coordinates['lng']
    url = Addressable::URI.new(
    :scheme => "https",
    :host => "maps.googleapis.com",
    :path => "maps/api/place/nearbysearch/json",
    :query_values => { :key => KEY, :location => "#{lat},#{lng}",
                       :sensor => false, :keyword => 'ice cream',
                       :rankby => 'distance' }
    )
    response = RestClient.get(url.to_s)
    JSON.parse(response)["results"].first["geometry"]["location"]
  end

  def directions(origin, destination)
    origin_lat, origin_lng = origin['lat'], origin['lng']
    destination_lat, destination_lng = destination['lat'], destination['lng']
    url = Addressable::URI.new(
    :scheme => "http",
    :host => "maps.googleapis.com",
    :path => "maps/api/directions/json",
    :query_values => { :origin => "#{origin_lat},#{origin_lng}",
                       :destination => "#{destination_lat},#{destination_lng}",
                       :sensor => false}
    )
    response = RestClient.get(url.to_s)
    JSON.parse(response)["routes"].first["legs"].first
  end

  def render(directions)
    puts "Starting From : #{directions["start_address"]}"
    directions["steps"].each do |step|
      puts Nokogiri::HTML(step["html_instructions"]).text
    end
    puts "Arrive at: #{directions["end_address"]}"

  end

  def directions_to_ice_cream
    origin = coordinates(get_address)
    destination = find_ice_cream(origin)
    render(directions(origin, destination))
  end

end
class Group < ApplicationRecord

  has_many :trips
  has_many :tests

  #### METHODS ####
  
  def run_test
    otp = OtpService.new(Config.otp_url)
    atis = AtisService.new(Config.atis_url, Config.atis_app_id)
    test = Test.create(group: self)
    test.comment = test.id 
    test.save 
    test.trips.each do |trip|
      otp_request, otp_response = otp.plan([trip.origin_lat, trip.origin_lng], [trip.destination_lat, trip.destination_lng], trip.time, arriveBy=trip.arrive_by, mode="TRANSIT,WALK")
      atis_request, atis_response = atis.plan_trip(trip.params)
      viewable = otp.viewable_url([trip.origin_lat, trip.origin_lng], [trip.destination_lat, trip.destination_lng], trip.time, arriveBy=trip.arrive_by, mode="TRANSIT,WALK")
      Result.create(trip: trip, test: test, 
                    otp_request: otp_request, otp_response: otp_response, otp_viewable_request: viewable,
                    atis_request: atis_request, atis_response: atis_response)
    end
  end

  def geocode_trips
    geocoder = GeocodingService.new
    self.trips.each do |trip|
      
      #Geocode Origin
      unless trip.origin_lat and trip.origin_lng
        res = geocoder.geocode(trip.origin)
        if res.first #The first value is a true/false indicating success
          trip.origin_lat, trip.origin_lng = res[1].first[:lat], res[1].first[:lon]
        end
      end

      #Geocode Destination
      unless trip.destination_lat and trip.destination_lng
        res = geocoder.geocode(trip.destination)
        if res.first #The first value is a true/false indicating success
          trip.destination_lat, trip.destination_lng = res[1].first[:lat], res[1].first[:lon]
        end
      end
      trip.save
    end
  end

  # Load new Trips from CSV
  def update_trips file
    require 'open-uri'
    require 'csv'
    trips_file = open(file)

    # Iterate through CSV.
    failed = false
    message = ""
    self.trips.delete_all
    line = 2 #Line 1 is the header, start with line 2 in the count
    begin
      CSV.foreach(trips_file, {:col_sep => ",", :headers => true}) do |row|

        begin
          Trip.create!({
            origin: row[0],
            origin_lat: row[1],
            origin_lng: row[2],
            destination: row[3],
            destination_lat: row[4],
            destination_lng: row[5],
            time: DateTime.strptime("#{row[6]} #{row[7]} -0500", "%m/%e/%y %l:%M %p %z"),
            arrive_by: row[8],
            group: self
          })
        rescue
          #Found an error, back out all changes and restore previous POIs
          message = 'Error found on line: ' + line.to_s
          Rails.logger.info message
          self.trips.delete_all
          failed = true
          break
        end
        line += 1
      end
    rescue
      failed = true
      message = 'Error Reading File'
      Rails.logger.info message
      self.trips.delete_all
      failed = true
    end

    if failed
      return false, message
    else
      return true, self.trips.count.to_s + " trips loaded"
    end

  end #Update

end

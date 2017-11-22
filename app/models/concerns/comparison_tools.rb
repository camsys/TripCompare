module ComparisonTools

  include TrapezeTools

  def otp_summary

    summary = []
    if self.otp_response["plan"]
      self.otp_response["plan"]["itineraries"].each do |itin|
        routes = []
        route_ids = []
        itin["legs"].each do |leg|
          unless leg["route"].blank?
            routes << leg["route"]
            route_ids << leg["routeId"]
          end
        end
        summary << {duration: itin["duration"], 
                    start_time: itin["startTime"], 
                    end_time: itin["endTime"], 
                    walk_time: itin["walkTime"], 
                    transit_time: itin["transitTime"], 
                    waiting_time: itin["waitingTime"],
                    walk_distance: itin["walkDistance"],
                    transfers: itin["transfers"],
                    routes: routes,
                    route_ids: route_ids}
      end
    end

    return summary 

  end

  def atis_summary
    summary = []

    itineraries = arrayify self.atis_response["Itin"]

    itineraries.each do |itin|
      routes = []

      if itin["Legs"] 
        legs = arrayify itin["Legs"]["Leg"]
        routes  = []
        route_ids  = []
        legs.each do |value|
          unless value["Service"].blank? 
            routes << value["Service"]["Publicroute"]
            route_ids << value["Service"]["Route"]
          end
        end

        summary << {duration: itin["Totaltime"].to_f*60, 
                    start_time: nil, 
                    end_time: nil,
                    walk_time: itin["Walktime"].to_f*60, 
                    transit_time: itin["Transittime"].to_f*60, 
                    waiting_time: nil,
                    walk_distance: nil,
                    transfers: [routes.count - 1, 0].max,
                    routes: routes,
                    route_ids: route_ids}
      end
    end

    return summary 

  end

  def get_percent_matched

    return self.percent_matched if self.percent_matched

    otp_routes = (self.otp_summary.map{ |i| i[:route_ids] }).uniq
    atis_routes = (self.atis_summary.map{ |i| i[:route_ids] }).uniq

    #Convert the ATIS Route IDs to GTFS Ids
    mapping = Config.atis_otp_mapping
    mapped_otp_routes = []
    otp_routes.each do |itinerary|
      this_itin = []
      itinerary.each do |route|
         this_itin << mapping[route.to_sym][:atis_id]
      end
      mapped_otp_routes << this_itin
    end

    match = 0.0
    mapped_otp_routes.each do |route|
      match += 1 if route.in? atis_routes 
    end

    self.percent_matched = match.to_f/otp_routes.count
    self.save
    return self.percent_matched

  end


  def compare_summary
    atis = arrayify(self.atis_response["Itin"]).first 
    otp = self.otp_response["plan"]["itineraries"].first 
    walk_time_ratio = otp["walkTime"].to_f/(atis["Walktime"].to_f*60)
    transit_time_ratio = otp["transitTime"].to_f/(atis["Transittime"].to_f*60)

    if (atis["Legs"].count == 0) and otp["transfers"] > 0
      transfers_ratio = "inf"
    elsif (atis["Legs"].count == 0) and otp["transfers"] == 0
      transfers_ratio = 1
    else
      transfers_ratio = otp["transfers"].to_f/(atis["Legs"].count.to_f)
    end

    return {walk_time: walk_time_ratio, transit_time: transit_time_ratio, transfer: transfers_ratio}
  end
end
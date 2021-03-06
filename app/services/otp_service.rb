require 'json'
require 'net/http'
require 'logger'
require 'uri'
class OtpService

  include OtpTools

  attr_accessor :base_url, :api_key

  def initialize(base_url, api_key)
      @base_url = base_url
      @api_key = api_key
  end

  def plan(
        from, to, trip_datetime,
        mode="TRANSIT,WALK", arriveBy=true, walk_speed=1.3, max_walk_distance=8046.72, walk_reluctance=4, transfer_penalty=600,
        wheelchair=false, banned_agencies=nil, banned_route_types=nil,
        transfer_slack=120, allow_unknown_transfers=false, use_unpreferred_routes_penalty=1200, use_unpreferred_start_end_penalty=3600, 
        other_than_preferred_routes_penalty=10800, car_reluctance=4, path_comparator='mta', max_walk_distance_heuristic=8047)

    # Hardcoded Defaults
    max_bicycle_distance=5
    optimize='QUICK'
    num_itineraries=3
    wheelchair=wheelchair.to_s.strip.empty? ? "false" : wheelchair.to_s
    min_transfer_time=nil
    max_transfer_time=nil
    preferred_routes=nil

    #walk_speed is defined in MPH and converted to m/s before going to OTP
    #max_walk_distance is defined in miles and converted to meters before going to OTP
    #Parameters
    time = trip_datetime.strftime("%-I:%M%p")
    date = trip_datetime.strftime("%Y-%m-%d")

    base_url = @base_url.to_s + '/plan?'
    url_options = "&time=" + time
    url_options += "&mode=" + mode + "&date=" + date
    url_options += "&toPlace=" + to[0].to_s + ',' + to[1].to_s + "&fromPlace=" + from[0].to_s + ',' + from[1].to_s
    url_options += "&wheelchair=" + wheelchair.to_s
    url_options += "&arriveBy=" + arriveBy.to_s
    url_options += "&walkSpeed=" + walk_speed.to_s
    url_options += "&showNextFromDeparture=true"

    url_options += "&transferSlack=" + transfer_slack.to_s
    url_options += "&allowUnknownTransfers=" + allow_unknown_transfers.to_s
    url_options += "&useUnpreferredRoutesPenalty=" + use_unpreferred_routes_penalty.to_s
    url_options += "&useUnpreferredStartEndPenalty=" + use_unpreferred_start_end_penalty.to_s
    url_options += "&otherThanPreferredRoutesPenalty=" + other_than_preferred_routes_penalty.to_s
    url_options += "&carReluctance=" + car_reluctance.to_s
    url_options += "&pathComparator=" + path_comparator.to_s
    url_options += "&maxWalkDistanceHeuristic=" + max_walk_distance_heuristic.to_s

    if banned_agencies
      url_options += "&bannedAgencies=" + banned_agencies
    end

    if banned_route_types
      url_options += "&bannedRouteTypes=" + banned_route_types
    end

    if preferred_routes
      url_options += "&preferredRoutes=" + preferred_routes
      url_options += "&otherThanPreferredRoutesPenalty=7200"#VERY High penalty for not using the preferred route
    end

    unless min_transfer_time.nil?
      url_options += "&minTransferTime=" + min_transfer_time.to_s
    end

    unless max_transfer_time.nil?
      url_options += "&maxTransferTime=" + max_transfer_time.to_s
    end



    #If it's a bicycle trip, OTP uses walk distance as the bicycle distance
    if mode == "TRANSIT,BICYCLE" or mode == "BICYCLE"
      url_options += "&maxWalkDistance=" + (1609.34*(max_bicycle_distance || 5.0)).to_s
    else
      url_options += "&maxWalkDistance=" + max_walk_distance.to_s
    end

    url_options += "&numItineraries=" + num_itineraries.to_s
    
    url_options += "&walkReluctance=" + walk_reluctance.to_s
    url_options += "&transferPenalty=" + transfer_penalty.to_i.to_s

    #APIKEY
    unless @api_key.blank? 
      url_options += "&apikey=#{@api_key}"
    end

    url = base_url + url_options
    puts url

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      return url, JSON.parse(resp.body)
    rescue Exception=>e
      return url, {'id'=>500, 'msg'=>e.to_s}
    end

    return url, {'id'=>500, 'msg'=>'Error'}

  end

  def viewable_url(
        from, to, trip_datetime,
        mode="TRANSIT,WALK", arriveBy=true, walk_speed=1.3, max_walk_distance=8046.72, walk_reluctance=4, transfer_penalty=600,
        wheelchair=false, banned_agencies=nil, banned_route_types=nil, transfer_slack=120, allow_unknown_transfers=false, use_unpreferred_routes_penalty=1200, use_unpreferred_start_end_penalty=3600, 
        other_than_preferred_routes_penalty=10800, car_reluctance=4, path_comparator='mta', max_walk_distance_heuristic=8047)

    #def viewable_url(from,
    #    to, trip_datetime, arriveBy=true, mode="TRANSIT,WALK", wheelchair="false", walk_speed=3.0,
    #    max_walk_distance=2, max_bicycle_distance=5, optimize='QUICK', num_itineraries=3,
    #    min_transfer_time=nil, max_transfer_time=nil, banned_routes=nil, preferred_routes=nil)

    # Hardcoded Defaults
    max_bicycle_distance=5
    optimize='QUICK'
    num_itineraries=3
    wheelchair=wheelchair.to_s.strip.empty? ? "false" : wheelchair.to_s
    min_transfer_time=nil
    max_transfer_time=nil
    banned_routes=nil
    preferred_routes=nil

    time = trip_datetime.strftime("%I:%M %p")
    date = trip_datetime.strftime("%m-%d-%Y")
    base_url = get_base_url(@base_url.to_s) + '/#plan?'
    url_options = "&time=" + time
    url_options += "&mode=" + mode + "&date=" + date
    url_options += "&toPlace=" + to[0].to_s + ',' + to[1].to_s + "&fromPlace=" + from[0].to_s + ',' + from[1].to_s
    url_options += "&wheelchair=" + wheelchair.to_s
    url_options += "&arriveBy=" + arriveBy.to_s
    url_options += "&walkSpeed=" + walk_speed.to_s
    url_options += "&showNextFromDeparture=true"

    url_options += "&transferSlack=" + transfer_slack.to_s
    url_options += "&allowUnknownTransfers=" + allow_unknown_transfers.to_s
    url_options += "&useUnpreferredRoutesPenalty=" + use_unpreferred_routes_penalty.to_s
    url_options += "&useUnpreferredStartEndPenalty=" + use_unpreferred_start_end_penalty.to_s
    url_options += "&otherThanPreferredRoutesPenalty=" + other_than_preferred_routes_penalty.to_s
    url_options += "&carReluctance=" + car_reluctance.to_s
    url_options += "&pathComparator=" + path_comparator.to_s
    url_options += "&maxWalkDistanceHeuristic=" + max_walk_distance_heuristic.to_s

    if banned_agencies
      url_options += "&bannedAgencies=" + banned_agencies
    end

    if banned_route_types
      url_options += "&bannedRouteTypes=" + banned_route_types
    end

    if preferred_routes
      url_options += "&preferredRoutes=" + preferred_routes
      url_options += "&otherThanPreferredRoutesPenalty=7200"#VERY High penalty for not using the preferred route
    end

    unless min_transfer_time.nil?
      url_options += "&minTransferTime=" + min_transfer_time.to_s
    end

    unless max_transfer_time.nil?
      url_options += "&maxTransferTime=" + max_transfer_time.to_s
    end

    #If it's a bicycle trip, OTP uses walk distance as the bicycle distance
    if mode == "TRANSIT,BICYCLE" or mode == "BICYCLE"
      url_options += "&maxWalkDistance=" + (1609.34*(max_bicycle_distance || 5.0)).to_s
    else
      url_options += "&maxWalkDistance=" + max_walk_distance.to_s
    end

    url_options += "&numItineraries=" + num_itineraries.to_s

    url_options += "&walkReluctance=" + walk_reluctance.to_s
    url_options += "&transferPenalty=" + transfer_penalty.to_i.to_s

    #APIKEY
    unless @api_key.blank? 
      url_options += "&apikey=#{@api_key}"
    end

    url = base_url + url_options

  end

  def last_built
    url = Setting.open_trip_planner
    resp = Net::HTTP.get_response(URI.parse(url))
    data = JSON.parse(resp.body)
    time = data['buildTime']/1000
    return Time.at(time)
  end

  def get_stops
    stops_path = '/index/stops'
    url = Setting.open_trip_planner + stops_path
    resp = Net::HTTP.get_response(URI.parse(url))
    return JSON.parse(resp.body)
  end

  def get_routes
    routes_path = '/index/routes'
    url = Setting.open_trip_planner + routes_path
    resp = Net::HTTP.get_response(URI.parse(url))
    return JSON.parse(resp.body)
  end

  def get_first_feed_id
    path = '/index/feeds'
    url = Setting.open_trip_planner + path
    resp = Net::HTTP.get_response(URI.parse(url))
    return JSON.parse(resp.body).first
  end

  def get_stoptimes trip_id, agency_id=1
    path = '/index/trips/' + agency_id.to_s + ':' + trip_id.to_s + '/stoptimes'
    url = Setting.open_trip_planner + path
    resp = Net::HTTP.get_response(URI.parse(url))
    return JSON.parse(resp.body)
  end

  def get_otp_mode trip_type
    hash = {'mode_transit' => 'TRANSIT,WALK',
    'mode_bicycle_transit'=> 'TRANSIT,BICYCLE',
    'mode_park_transit'=>'CAR_PARK,WALK,TRANSIT',
    'mode_car_transit'=>'CAR,WALK,TRANSIT',
    'mode_bike_park_transit'=>:'BICYCLE_PARK,WALK,TRANSIT',
    'mode_rail'=>'TRAINISH,WALK',
    'mode_bus'=>'BUSISH,WALK',
    'mode_walk'=>'WALK',
    'mode_car'=>'CAR',
    'mode_bicycle'=>'MODE_BICYCLE'}
    hash[trip_type.to_sym]
  end

  def get_base_url url
    uri = URI.parse(url)
    base =  "#{uri.scheme}://#{uri.host}"
    return base
  end

end
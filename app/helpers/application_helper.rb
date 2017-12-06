module ApplicationHelper
  # Allows named yields within partial layouts
  def yield_content(content_key)
    view_flow.content.delete(content_key)
  end

  def otp_time_str otp_time
    #OTP Time comes in as Epoch integer
    Time.at(otp_time.to_i/1000).in_time_zone.strftime("%I:%M %p")
  end

  def atis_time_str atis_time
    #ATIS time comes in as a string in the format HHMM" 
    ampm = "AM"
    hours = atis_time[0..1]
    mins = atis_time[2..3]

    if hours.to_i == 00
      hours = "12"
    elsif hours.to_i > 12
      hours = (hours.to_i - 12).to_s
      ampm = "PM"
    elsif hours.to_i == 12
      ampm = "PM"
    end
      
    "#{hours}:#{mins} #{ampm}"

  end
end

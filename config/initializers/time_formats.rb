#http://api.rubyonrails.org/classes/ActiveSupport/CoreExtensions/Time/Conversions.html

# DATE_FORMATS={ 
#   :db => "%Y-%m-%d %H:%M:%S", 
#   :number => "%Y%m%d%H%M%S", 
#   :time => "%H:%M", 
#   :short => "%d %b %H:%M", 
#   :long => "%B %d, %Y %H:%M", 
#   :long_ordinal => lambda { |time| time.strftime("%B #{time.day.ordinalize}, %Y %H:%M") }, 
#   :rfc822 => lambda { |time| time.strftime("%a, %d %b %Y %H:%M:%S #{time.formatted_offset(false)}") }
# }

Time::DATE_FORMATS[:nl] = "%H:%M %d.%m.%Y"

module ApplicationHelper

  def resque_status
    Resque.redis #check if we can connect to redis server
    Resque.workers.any? ? :ok : :no_worker
    rescue
      :no_server
  end

  # http://stackoverflow.com/questions/2430249/rails-distance-of-time-not-in-words
  def distance_of_time(from_time, to_time, include_seconds = false, options = {})
    diff = (to_time - from_time).abs
    s = Struct.new(:weeks, :days, :hours, :minutes, :seconds).new
    day_diff    = diff % 1.week.seconds
    s.weeks     = ((diff - day_diff) / 1.week.seconds).to_i
    hour_diff   = day_diff % 1.day.seconds
    s.days      = ((day_diff - hour_diff) / 1.day.seconds).to_i
    minute_diff = hour_diff % 1.hour.seconds
    s.hours     = ((hour_diff - minute_diff) / 1.hour.seconds).to_i
    second_diff = minute_diff % 1.minute.second
    s.minutes   = ((minute_diff - second_diff) / 1.minute.seconds).to_i
    fractions   = second_diff % 1
    s.seconds   = (second_diff - fractions).to_i
    [].tap do |time|
      time << "#{s.weeks}w" if s.weeks > 0
      time << "#{s.days}d" if s.days > 0
      time << "#{s.hours}h" if s.hours > 0
      time << "#{s.minutes}m" if !include_seconds || s.minutes > 0
      time << "#{s.seconds}s" if include_seconds
    end.join(' ')
  end
end

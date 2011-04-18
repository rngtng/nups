module Stats
  #dependen on:
  # recipients_count, oks, fails, start_at, finished_at
  
  def progress_percent
    return 0 if self.recipients_count < 1
    (100 * count / self.recipients_count).round
  end
  
  #How long did it take to send newsletter
  def sending_time
    return 0 unless self.start_at
    ((self.finished_at || Time.now) - self.start_at).to_f
  end
  
  def count
    self.oks + self.fails
  end
  
  def sendings_per_second
    return 0 if sending_time < 1
    return self.oks.to_f / sending_time
  end
end
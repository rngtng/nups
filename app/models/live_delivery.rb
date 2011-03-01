class LiveDelivery < Delivery
  # before_save

  def recipients_all
    self.newsletter.recipients.greater_than(self.last_sent_id)
  end

  def send_to!(recipient)
    super(recipient)    
    self.update_only(:oks => self.oks + 1, :last_id => recipient.id)
    log("#{self.newsletter.id} send to #{recipient.email} (#{recipient.id})")
  rescue  => exp
    recipient.errors_count += 1
    recipient.errors << "\n#{self.id} = " << exp.message
    recipient.save

    self.update_only(:errors => self.errors + 1, :last_id => recipient.id)
  ensure
    self.reload
  end

  private
  def set_recipients
    recipients = 0
    recipients = recipients_all.count
  end
end
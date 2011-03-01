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

# == Schema Info
#
# Table name: deliveries
#
#  id               :integer(4)      not null, primary key
#  last_id          :integer(4)      not null, default(0)
#  newsletter_id    :integer(4)
#  bounces          :integer(4)      not null, default(0)
#  fails            :integer(4)      not null, default(0)
#  oks              :integer(4)      not null, default(0)
#  recipients_count :integer(4)
#  state            :string(255)
#  type             :string(255)
#  created_at       :datetime
#  finished_at      :datetime
#  start_at         :datetime
#  updated_at       :datetime
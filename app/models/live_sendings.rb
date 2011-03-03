class LiveSending < Sending

  def recipients
    self.newsletter.recipients.greater_than(self.last_id)
  end

  private
  def send_to!(recipient)
    self.last_id = recipient.id
    super(recipient)
    self.oks =+ 1
    log("#{self.newsletter.id} send to #{recipient.email} (#{recipient.id})")
  rescue  => exp
    recipient.failed_deliveries.create!(:message => exp.message, :sending => self)
  ensure
    self.save!
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
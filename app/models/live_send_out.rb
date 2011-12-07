class LiveSendOut < SendOut

  validates :recipient_id, :presence => true, :uniqueness => {:scope => [:newsletter_id, :type]}, :on => :create

  before_validation :set_email, :on => :create

  state_machine :initial => :sheduled do
    before_transition :delivering => :finished do |me|
      me.finished_at = Time.now
      me.recipient.update_attribute(:deliveries_count,  me.recipient.deliveries_count + 1)
    end

    before_transition :delivering => :failed do |me|
      me.recipient.update_attribute(:failed_count,  me.recipient.failed_count + 1)
    end

    before_transition :finished => :read do |me|
      me.recipient.update_attribute(:reads_count,  me.recipient.reads_count + 1)
    end

    before_transition :finished => :bounced do |me|
      me.recipient.update_attribute(:bounces_count,  me.recipient.bounces_count + 1)
    end
  end

  def issue_id
    ["ma", self.id, self.recipient_id].join('-')
  end

  private
  def set_email
    self.email = recipient.email
  end
end

# == Schema Info
#
# Table name: send_outs
#
#  id            :integer(4)      not null, primary key
#  newsletter_id :integer(4)
#  recipient_id  :integer(4)
#  email         :string(255)
#  error_code    :string(255)
#  error_message :text
#  state         :string(255)
#  type          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
class LiveSendOut < SendOut

  validates :recipient_id, :presence => true, :uniqueness => {:scope => [:newsletter_id, :type]}, :on => :create

  before_validation :set_email, :on => :create

  state_machine :initial => :sheduled do
    before_transition :delivering => :finished do |me|
      me.finished_at = Time.now
      me.recipient.update_attribute(:deliveries_count,  me.recipient.deliveries_count + 1)
    end

    before_transition :delivering => :failed do |me, transition|
      me.error_message = transition.args[0].message
      me.recipient.update_attribute(:fails_count,  me.recipient.fails_count + 1)
    end

    after_transition :delivering => :failed do |me, transition|
      # a bit dirty hack: force to end transition successfull but still
      # propagade execption
      me.connection.execute("COMMIT") #prevent rollback
      Airbrake.notify(transition.args[0], :params => { :id => self.id })
      raise transition.args[0]
    end

    before_transition :finished => :read do |me|
      me.recipient.update_attribute(:reads_count,  me.recipient.reads_count + 1)
    end

    before_transition :finished => :bounced do |me, transition|
      me.error_message = transition.args[0]
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

# == Schema Information
#
# Table name: send_outs
#
#  id            :integer(4)      not null, primary key
#  recipient_id  :integer(4)
#  newsletter_id :integer(4)
#  type          :string(255)
#  state         :string(255)
#  email         :string(255)
#  error_message :text
#  created_at    :datetime
#  updated_at    :datetime
#  finished_at   :datetime
#

#  updated_at    :datetime

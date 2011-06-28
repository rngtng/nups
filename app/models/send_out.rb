class SendOut < ActiveRecord::Base
  QUEUE = :nups_send_outs

  belongs_to :newsletter
  belongs_to :recipient

  validates :newsletter_id, :presence => true
  validates :email, :presence => true

  after_save :async_deliver!

  state_machine :initial => :sheduled do
    event :deliver do
      transition :sheduled => :delivering
    end

    event :resume do
      transition :stopped => :sheduled
    end

    event :stop do
      transition :sheduled => :stopped
    end

    event :finish do
      transition :delivering => :finished
    end

    event :failure do
      transition :delivering => :failed
    end

    event :bounce do
      transition :finished  => :bounced
    end

    after_transition :sheduled => :delivering do |me|
      begin
        me.issue.deliver
        me.finish!
      rescue Exception => e
        me.error_message = e.message
        me.failure! #(e.message)
      end
    end

  end

  ########################################################################################################################

  def self.queue
    QUEUE
  end

  def self.perform(id)
    a = find(id, :include => [:newsletter, :recipient])
    a.deliver!
  end

  def issue
    @issue ||= NewsletterMailer.issue(self.newsletter, self.recipient).tap do |issue|
      issue.header["X-MA-Id"] = issue_id
    end
  end

  private
  def async_deliver!
    if sheduled?
      Resque.enqueue(self.class, self.id)
    end
  end
end

class LiveSendOut < SendOut

  validates :recipient_id, :presence => true, :uniqueness => {:scope => [:newsletter_id, :type]}

  before_validation :set_email

  def issue_id
    ["ma", self.id, self.recipient_id].join('-')
  end

  private
  def set_email
    self.email = recipient.email
  end
end

class TestSendOut < SendOut

  def recipient
    @recipient ||= Recipient.new(:email => email)
  end

  def issue_id
    ["ma", self.id, "test"].join('-')
  end

  def issue
    super.tap do |issue|
      issue.subject = "TEST: #{issue.subject}"
    end
  end
end


# == Schema Info
#
# Table name: send_outs
#
#  id            :integer(4)      not null, primary key
#  newsletter_id :integer(4)
#  recipient_id  :integer(4)
#  error_code    :string(255)
#  error_message :text
#  params        :string(255)
#  type          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
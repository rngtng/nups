class SendOut < ActiveRecord::Base
  QUEUE = :nups_send_outs

  belongs_to :newsletter
  belongs_to :recipient

  validates :newsletter_id, :presence => true

  def self.queue
    QUEUE
  end

  def self.perform(id)
    self.find(id, :include => [:newsletter, :recipient]).start!
  end

  def start!
  end

  private
  def async_start!
    Resque.enqueue(self.class, self.id)
  end
end

class LiveSendOut < SendOut

  after_create :async_start!

  validates :recipient_id, :presence => true, :uniqueness => {:scope => [:newsletter_id, :type]}

  def start!
    issue                   = NewsletterMailer.issue(self.newsletter, self.recipient)
    issue.header["X-MA-Id"] = ["ma", self.id, self.recipient_id].join('-')
    issue.deliver

    self.update_attributes(:type => "FinishedSendOut", :updated_at => Time.now)

  rescue => e
    self.update_attributes(:type => "FailedSendOut", :error_message => e.message, :updated_at => Time.now)
  end
end

class TestSendOut < SendOut

  after_create :async_start!

  def start!
    recipient               = Recipient.new(:email => "test@c-art-web.de")
    issue                   = NewsletterMailer.issue(self.newsletter, recipient)
    issue.header["X-MA-Id"] = ["ma", self.id, "test"].join('-')
    issue.subject           = "TEST: #{issue.subject}"

    issue.deliver
    self.update_attributes(:updated_at => Time.now)

  rescue => e
    self.update_attributes(:message => e.message, :updated_at => Time.now)
  end
end

class FinishedSendOut < SendOut
end

class FailedSendOut < SendOut
end

class BouncedSendOut < SendOut
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
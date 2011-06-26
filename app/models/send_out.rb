class SendOut < ActiveRecord::Base
  belongs_to :newsletter
  belongs_to :recipient
end

class LiveSendOut < SendOut
  include SendOutable

  with_options(:presence => true) do |present|
    present.validates :newsletter_id
    present.validates :recipient_id
  end

  validates :recipient_id, :scope => [:newsletter_id, :type]

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
  include SendOutable

  with_options(:presence => true) do |present|
    present.validates :newsletter_id
  end

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

module SendOutable
  QUEUE = :nups_send_outs

  def self.queue
    QUEUE
  end

  after_create :async_start!

  def self.perform(id)
    SendOut.find(id, :include => [:newsletter, :recipient]).start!
  end

  private
  def async_start!
    Resque.enqueue(LiveSendOut, self.id)
  end
end
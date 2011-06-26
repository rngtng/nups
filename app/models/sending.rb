class Sending < ActiveRecord::Base
  include Stats

  QUEUE = :nups_sending

  belongs_to :newsletter
  belongs_to :recipient

  with_options(:presence => true) do |present|
    present.validates :newsletter_id
    present.validates :recipient_id
    #present.validates :start_at
  end

  after_create :async_start!

  def self.queue
    QUEUE
  end

  def self.perform(id)
    Sending.find(id, :include => [:newsletter, :recipient]).start!
  end

  private
  def async_start!
    Resque.enqueue(Sending, self.id)
  end
end

class LiveSending < ActiveRecord::Base

  validates :recipient_id, :scope => [:newsletter_id, :type]

  def start!
    issue                   = NewsletterMailer.issue(self.newsletter, self.recipient)
    issue.header["X-MA-Id"] = ["ma", self.id, self.recipient_id].join('-')
    issue.deliver

    self.update_attributes(:type => "FinishedSending", :updated_at => Time.now)

  rescue => e
    self.update_attributes(:type => "FailedSending", :message => e.message, :updated_at => Time.now)
  end
end

class TestSending < ActiveRecord::Base
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

# == Schema Info
#
# Table name: sendings
#
#  id               :integer(4)      not null, primary key
#  last_id          :integer(4)      not null, default(0)
#  newsletter_id    :integer(4)
#  fails            :integer(4)      not null, default(0)
#  oks              :integer(4)      not null, default(0)
#  recipients_count :integer(4)
#  state            :string(255)
#  type             :string(255)
#  created_at       :datetime
#  finished_at      :datetime
#  start_at         :datetime
#  updated_at       :datetime
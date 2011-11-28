require 'bounce_email'

class Bounce < ActiveRecord::Base

  QUEUE = :nups2_bounces

  belongs_to :account # deprecated
  belongs_to :send_out
  belongs_to :recipient

  validates :account_id, :presence => true # deprecated
  validates :raw, :presence => true

  after_create :schedule_for_processing

  def self.queue
    Bounce::QUEUE
  end

  def self.perform(id)
    self.find(id).process!
  end

  def mail
    @mail ||= ::BounceEmail::Mail.new(self.raw)
  end

  def mail_id
    @mail_id ||= Array(mail.body.to_s.match(/#{Newsletter::HEADER_ID}:? ?([^\r\n ]+)/))[1]
  end

  def process!
    if mail.bounced? && mail_id
      mail_id_split = mail_id.split('-')
      if mail_id_split.size == 3
        _, self.send_out_id, self.recipient_id = *mail_id_split
      else
        _, self.account_id, newsletter_id, self.recipient_id = *mail_id_split
      end

      self.send_at      = mail.date
      self.subject      = mail.subject
      self.from         = mail.from.join(';')
      self.header       = mail.header.to_s
      self.body         = mail.body.decoded
      self.error_status = mail.error_status
      self.save!
    end
  end

  def schedule_for_processing
    Resque.enqueue(Bounce, self.id)
  end

end


# == Schema Info
#
# Table name: bounces
#
#  id         :integer(4)      not null, primary key
#  account_id :integer(4)
#  user_id    :integer(4)
#  body       :text
#  from       :string(255)
#  header     :text
#  raw        :text
#  subject    :string(255)
#  created_at :datetime
#  send_at    :datetime
#  updated_at :datetime
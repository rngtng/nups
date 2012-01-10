require 'bounce_email'

class Bounce < ActiveRecord::Base

  QUEUE = :nups_bounces

  belongs_to :send_out
  belongs_to :recipient

  validates :raw, :presence => true

  after_create :schedule_for_processing
  after_save :update_send_out

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
      _, self.send_out_id, self.recipient_id = mail_id.split('-')

      self.send_at      = mail.date
      self.subject      = mail.subject
      self.from         = Array(mail.from).join(';')
      self.header       = mail.header.to_s
      self.body         = mail.body.decoded
      self.error_status = mail.error_status
      self.save!
    end
  end

  def schedule_for_processing
    Resque.enqueue(Bounce, self.id)
  end

  def error_message
    "#{mail.diagnostic_code} #{mail.error_status}"
  end

  def update_send_out
    send_out.bounce!(self.error_message) if send_out
  end
end

# == Schema Information
#
# Table name: bounces
#
#  id           :integer(4)      not null, primary key
#  account_id   :integer(4)
#  recipient_id :integer(4)
#  from         :string(255)
#  subject      :string(255)
#  send_at      :datetime
#  header       :text
#  body         :text
#  raw          :text
#  created_at   :datetime
#  updated_at   :datetime
#  error_status :string(255)
#  send_out_id  :integer(4)
#

#  updated_at   :datetime

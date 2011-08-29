require 'bounce_email'

class Bounce < ActiveRecord::Base

  belongs_to :account
  belongs_to :recipient

  validates :account_id, :presence => true
  validates :raw, :presence => true

  before_validation :process, :set_meta

  def mail
    @mail ||= ::BounceEmail::Mail.new(self.raw)
  end

  def mail_id
    @mail_id ||= Array(mail.body.to_s.match(/X-MA-Id:? ?([^\r\n ]+)/))[1]
  end

  def process
    if mail.bounced? && mail_id
      dummy, account_id, newsletter_id, recipient_id = mail_id.split('-')
      if r = Recipient.find_by_account_id_and_id(account_id, recipient_id)
        rec = Array(mail.final_recipient).split(";")[1].try(:strip)
        unless r.bounces.to_s.include?(mail_id)
          r.bounces_count += 1
          r.bounces = "#{mail.date.strftime("%Y-%m-%d")} #{mail_id} <#{rec}>: #{mail.error_status} #{mail.diagnostic_code}\n#{r.bounces}"
          r.save!
        end
        self.raw = nil
      end
    end
  end

  private
  def set_meta
    self.send_at = mail.date
    self.subject = mail.subject
    self.from    = mail.from.join(';')
    self.header  = mail.header.to_s
    self.body    = mail.body.decoded
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
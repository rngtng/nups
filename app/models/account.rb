require 'net/imap'
require 'bounce_email'

class Account < ActiveRecord::Base

  belongs_to :user

  has_many :assets
  has_many :newsletters
  has_many :recipients

  validates_presence_of :user_id

  def test_recipients(additional_emails = nil)
    (test_recipient_emails_array + Array(additional_emails)).uniq.map do |email|
      dummy_user = recipients.new(:email => email)
      dummy_user.readonly!
      dummy_user.valid? ? dummy_user : nil
    end.compact
  end

  def test_recipient_emails_array
    @test_recipient_emails_array = test_recipient_emails.to_s.split(/,|;|\n|\t/).map(&:strip)
  end

  def mail_config
    @mail_config ||= YAML::load(self.mail_config_raw)
  rescue
    nil
  end

  def from_email
    email_exp = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)
    self.from.scan(email_exp).first
  end

  def sender
    @sender   ||= (self.mail_config && self.mail_config['sender']) || self.from_email
  end

  def reply_to
    @reply_to ||= (self.mail_config && self.mail_config['reply_to']) || self.from_email
  end

  def process_bounces
    mail_settings = mail_config['smtp_settings']

    imap = Net::IMAP.new(mail_settings[:address].gsub('smtp', 'imap'))
    imap.authenticate('LOGIN', mail_settings[:user_name], mail_settings[:password])
    imap.select('INBOX') #use examaine fpr read only

    # all msgs
    sources = {}
    imap.uid_search(["SINCE", "1-Jan-1969", "NOT", "DELETED"]).each do |id|
      out = "BOUNCE #{id}"
      begin
        mail = BounceEmail::Mail.new imap.uid_fetch(id, ['RFC822']).first.attr['RFC822']
        if mail.bounced? && (mail_id = Array(mail.body.match(/X-MA-Id:? ?([^\r\n ]+)/))[1])
          out << " - bounced id: #{mail_id}"
          dummy, account_id, newsletter_id, recipient_id = mail_id.split('-')
          if r = Recipient.find_by_account_id_and_id(account_id, recipient_id)
            out << " - found"
            rec = Array(mail.final_recipient).split(";")[1].try(:strip)
            unless r.bounces.to_s.include?(mail_id)
              r.bounces_count += 1
              r.bounces = "#{mail.date.strftime("%Y-%m-%d")} #{mail_id} <#{rec}>: #{mail.error_status} #{mail.diagnostic_code}\n#{r.bounces}"
              r.save!
              out << " - saved"
            end
          end
          imap.uid_store(id, "+FLAGS", [:Deleted])
        end
      rescue => e
        logger.warn " -------> error on #{id} #{e.message}"
      end
      logger.info out
    end
    imap.expunge
    imap.close
  end
end

# == Schema Info
#
# Table name: accounts
#
#  id                    :integer(4)      not null, primary key
#  user_id               :integer(4)
#  color                 :string(255)     default("#FFF")
#  from                  :string(255)
#  has_attachments       :boolean(1)
#  has_html              :boolean(1)      default(TRUE)
#  has_scheduling        :boolean(1)
#  has_text              :boolean(1)      default(TRUE)
#  mail_config           :text
#  name                  :string(255)
#  subject               :string(255)
#  template_html         :text
#  template_text         :text
#  test_recipient_emails :text
#  created_at            :datetime
#  updated_at            :datetime

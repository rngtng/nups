require 'net/imap'

class Account < ActiveRecord::Base

  belongs_to :user

  attr_protected :permalink

  has_many :assets,      :dependent => :destroy
  has_many :newsletters, :dependent => :destroy
  has_many :recipients,  :dependent => :destroy

  validates :user_id, :presence => true
  validates :permalink, :presence => true, :uniqueness => true, :on => :create

  scope :with_mail_config, :conditions => "mail_config_raw != ''"

  def self.queue
    Bounce::QUEUE
  end

  def self.perform(id = nil)
    if id
      self.find(id).process_bounces
    else
      Account.all.each do |account|
        Resque.enqueue(Account, account.id)
      end
    end
  end

  def test_recipient_emails_array
    @test_recipient_emails_array ||= begin
      tester = $mail_config['test_recipient_emails'].to_s + ' ' + test_recipient_emails.to_s
      tester.split(/,| |\||;|\r|\n|\t/).select do |email|
        email.include?('@')
      end.compact.uniq
    end
  end

  def mail_config
    @mail_config ||= YAML::load(self.mail_config_raw) || $mail_config
  rescue
    $mail_config
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

  def process_bounces(mbox = 'INBOX', encoding = 'RFC822')
    if mail_config && (mail_settings = mail_config['smtp_settings'])
      Net::IMAP.new(mail_settings[:address].gsub('smtp', 'imap')).tap do |imap|
        imap.authenticate('LOGIN', mail_settings[:user_name], mail_settings[:password])
        imap.select(mbox) #use examaine for read only

        # all msgs
        if imap.status(mbox, ["MESSAGES"])["MESSAGES"] > 0
          imap.uid_search(["SINCE", "1-Jan-1969", "NOT", "DELETED"]).each do |uid|
            begin
              Bounce.create!(:raw => imap.uid_fetch(uid, [encoding]).first.attr[encoding])
              imap.uid_store(uid, "+FLAGS", [:Deleted])
            rescue => e
              Airbrake.notify(
                :error_class   => "Bounce Error",
                :error_message => "Bounce Error: #{e.message}",
                :parameters    => {:account_id => self.id, :uid => uid}
              )
            end
          end
        end
        imap.expunge
        imap.close
      end
    end
  end

  protected
  # in case we generate a duplicate confirm_code, regenerate a new one
  def run_validations!
    super.tap do
      if errors[:permalink].present?
        self.permalink = SecureRandom.hex(8)
        return valid? #re-run validation
      end
    end
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
#  mail_config_raw       :text
#  name                  :string(255)
#  permalink             :string(255)
#  subject               :string(255)
#  template_html         :text
#  template_text         :text
#  test_recipient_emails :text
#  created_at            :datetime
#  updated_at            :datetime
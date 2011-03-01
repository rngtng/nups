class Newsletter < ActiveRecord::Base

  belongs_to :account
  has_many :recipients, :through => :account
  has_many :attachments, :class_name => 'Asset'

  has_many :deliveries

  #scope :live, :conditions => { :mode => Newsletter::LIVE_MODE }
  scope :with_account, lambda { |account|  account ? where(:account_id => account.id) : {} }

  validates :account_id, :presence => true
  validates :subject,    :presence => true

  with_options(:to => :account) do |account|
    %w(from host sender reply_to recipients test_recipients template_html template_text color has_html? has_text?).each do |attr|
      account.delegate attr
    end
  end

  ########################################################################################################################

  def route
    [self.account, self]
  end

  def attachment_ids=(attachment_ids)
    self.attachments = []
    attachment_ids.each do |attachment_id|
      if asset = account.assets.where(:id => attachment_id).first
        self.attachments << asset
      end
    end
  end

  def delivery
    @delivery ||= self.deliveries.current.first
  end

  ########################################################################################################################

  def created?
    !self.delivery
  end

  def scheduled?
    self.delivery.try(:scheduled?)
  end

  def running?
    self.delivery.try(:running?)
  end
  ########################################################################################################################

  def deliver_test!( args = {} )
    self.test_deliveries.create!
  end

  def deliver_live!( args = {} )
    raise if self.delivery #check sth not sheduled/running?
    self.live_deliveries.create!
  end

  def stop!
    self.delivery.try(:stop!)
  end

  def resume!
    raise if self.delivery #check sth running?
    self.live_deliveries.create!( :last_id => self.delivery.try(:last_id) )
  end

  def send_to!(recipient)
    NewsletterMailer.issue(self, recipient).deliver
  end

end

# == Schema Info
#
# Table name: newsletters
#
#  id                  :integer(4)      not null, primary key
#  account_id          :integer(4)
#  last_sent_id        :integer(4)
#  content             :text
#  deliveries_count    :integer(4)      not null, default(0)
#  errors_count        :integer(4)      not null, default(0)
#  mode                :integer(4)      not null, default(0)
#  recipients_count    :integer(4)      not null, default(0)
#  status              :integer(4)      not null, default(0)
#  subject             :string(255)
#  created_at          :datetime
#  deliver_at          :datetime
#  delivery_ended_at   :datetime
#  delivery_started_at :datetime
#  updated_at          :datetime
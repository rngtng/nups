class Newsletter < ActiveRecord::Base

  belongs_to :account

  has_many :recipients,  :through => :account
  has_many :attachments, :class_name => 'Asset'

  has_many :sendings, :dependent => :destroy
  has_many :live_sendings
  has_many :test_sendings

  #scope :live, :conditions => { :mode => Newsletter::LIVE_MODE }
  scope :with_account, lambda { |account|  account ? where(:account_id => account.id) : {} }

  validates :account_id, :presence => true
  validates :subject,    :presence => true

  with_options(:to => :account) do |account|
    %w(from host sender reply_to recipients test_recipients color has_html? has_text?).each do |attr|
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

  def sending
    self.live_sendings.latest.first
  end

  ########################################################################################################################
  def template_html
    account.template_html || "<%= content %>"
  end

  def template_text
    account.template_text || "<%= content %>"
  end

  ########################################################################################################################

  # def created?
  #   !self.delivery
  # end
  #
  # def scheduled?
  #   self.delivery.try(:scheduled?)
  # end
  #
  # def running?
  #   self.delivery.try(:running?)
  # end

  ########################################################################################################################

  def send_test!( args = {} )
    self.test_sendings.create!
  end

  def send_live!( args = {} )
    #check if test is available?
    self.live_sendings.create!( :last_id => self.live_sendings.last_f.try(:last_id) )
  end
  alias_method :send_live!, :resume!

  def stop!
    self.sending.try(:stop!)
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
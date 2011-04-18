class Newsletter < ActiveRecord::Base
  include Stats

  belongs_to :account

  has_many :recipients,  :through => :account
  has_many :attachments, :class_name => 'Asset'

  has_many :sendings,      :order => "updated_at DESC", :dependent => :destroy
  has_many :live_sendings, :order => "updated_at DESC"
  has_many :test_sendings, :order => "updated_at DESC"

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

  state_machine :initial => :new do
    event :send_test do
      transition :new     => :testing
      transition :tested  => :testing
      transition :stopped => :testing
    end

    event :send_live do
      transition :tested  => :sending
      transition :stopped => :sending
    end

    event :stop do
      transition :sending => :stopping
    end

    event :finish do
      transition :sending  => :finished
      transition :testing  => :tested
      transition :stopping => :stopped
    end

    event :clone do
      transition :finished => :finished
    end

    after_transition all => :testing do |me|
      me.test_sendings.create!
    end

    after_transition all => :sending do |me|
      me.live_sendings.create!( :last_id => me.last_id )
    end

    after_transition all => :stopping do |me|
      me.sendings.first.stop!
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

  ########################################################################################################################
  def template_html
    account.template_html || "<%= content %>"
  end

  def template_text
    account.template_text || "<%= content %>"
  end
  ########################################################################################################################

  #%w(recipients_count oks fails start_at finished_at).each do |method|
  def start_at
    self.live_sendings.last.try(:start_at)
  end

  def finished_at
    self.live_sendings.first.finished_at
  end

  def oks
    self.live_sendings.map(&:oks).sum
  end

  def fails
    self.live_sendings.map(&:fails).sum
  end

  def recipients_count
    self.live_sendings.first.try(:recipients_count) || 0
  end

  ########################################################################################################################
  #
  # def test_ok?
  #   self.test_sendings.finished.any?
  # end
  #
  # def running?
  #   self.sendings.scheduled_or_running.any?
  # end
  #
  # def finished?
  #   self.live_sendings.finished.any?
  # end
  #
  # def stopped?
  #   !finished? && self.live_sendings.stopped.any?
  # end
  #
  ########################################################################################################################

  def last_id
    self.live_sendings.first.try(:last_id) || 0
  end

end

# == Schema Info
#
# Table name: newsletters
#
#  id                  :integer(4)      not null, primary key
#  account_id          :integer(4)
#  content             :text
#  subject             :string(255)
#  created_at          :datetime
#  updated_at          :datetime
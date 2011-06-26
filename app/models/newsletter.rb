class Newsletter < ActiveRecord::Base
  include Stats

  QUEUE = :nups_newsletter

  belongs_to :account

  has_many :recipients,  :through => :account
  has_many :attachments, :class_name => 'Asset'

  has_many :send_outs,   :dependent => :destroy
  has_many :live_send_outs
  has_many :test_send_outs

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
      transition :testing => :new
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
      Resque.enqueue(me.class, me.id, "shedule_test!")
    end

    after_transition all => :sending do |me|
      Resque.enqueue(me.class, me.id, "shedule_live!")
    end

    after_transition all => :stopping do |me|
      Resque.enqueue(me.class, me.id, "stop!")
    end
  end

  ########################################################################################################################

  def self.queue
    QUEUE
  end

  def self.perform(id, action)
    self.find(id).send(action)
  end

 #-------------------------------------------------------------------------------------------------------------------------

  def shedule_test!
    self.test_recipients.each do |test_recipient|
      self.test_send_outs.create!(:params => test_recipient)
    end
  end

  def shedule_live!
    self.test_recipients.each do |live_recipient|
      self.live_send_outs.create!(:recipient => live_recipient)
    end
  end

  def stop!
    self.live_send_outs.map(&:stop!) #TODO use magice mysql here
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

end

# == Schema Info
#
# Table name: newsletters
#
#  id         :integer(4)      not null, primary key
#  account_id :integer(4)
#  content    :text
#  state      :string(255)
#  subject    :string(255)
#  created_at :datetime
#  updated_at :datetime
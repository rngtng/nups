class Newsletter < ActiveRecord::Base

  QUEUE = :nups_newsletter
  HEADER_ID = "X-MA-Id"
  DEFAULT_CONTENT = "<%= content %>"

  belongs_to :account

  has_many :recipients,  :through => :account, :conditions => { 'recipients.state' => :confirmed }
  has_many :attachments, :class_name => 'Asset'

  has_many :send_outs,   :dependent => :destroy
  has_many :live_send_outs
  has_many :test_send_outs

  scope :with_account, lambda { |account|  account ? where(:account_id => account.id) : {} }

  validates :account_id, :presence => true
  validates :subject,    :presence => true

  with_options(:to => :account) do |account|
    %w(from host sender reply_to test_recipient_emails_array color has_html? has_text?).each do |attr|
      account.delegate attr
    end
  end

  before_create :set_recipients_count

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

    event :resume_live do
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

    event :duplicate do
      transition :finished => :finished
    end

    after_transition all => :testing do |me|
      Resque.enqueue(me.class, me.id, "_send_test!")
    end

    after_transition :tested => :sending do |me|
      if me.deliver_at
        Resque.enqueue_at(me.deliver_at, me.class, me.id, "_send_live!")
      else
        Resque.enqueue(me.class, me.id, "_send_live!")
      end
    end

    after_transition :stopped => :sending do |me|
      Resque.enqueue(me.class, me.id, "_resume_live!")
    end

    after_transition all => :stopping do |me|
      Resque.enqueue(me.class, me.id, "_stop!")
    end
  end

  ########################################################################################################################

  def self.queue
    QUEUE
  end

  def self.perform(id, action)
    self.find(id).send(action)
  end

  ########################################################################################################################

  def route
    [self.account, self]
  end

  def attachment_ids=(attachment_ids)
    self.attachments.clear
    attachment_ids.each do |attachment_id|
      if attachment_id.present? && (asset = account.assets.find_by_id(attachment_id)) #attachment_id.blank? &&
        self.attachments << asset
      end
    end
  end

  def draft=(draft)
    return unless draft
    %w(subject content).each do |method|
      self.send("#{method}=", draft.send(method))
    end
  end

  ########################################################################################################################

  def template
    account.template_html.tap do |t|
      return DEFAULT_CONTENT if t.blank?
    end
  end

  def template_text
    account.template_text.tap do |t|
      return "" if t.blank?
    end
  end

  def progress_percent
    return 0 if self.recipients_count.to_i < 1
    (100 * count / self.recipients_count).round
  end

  #How long did it take to send newsletter
  def sending_time
    ((self.delivery_ended_at || Time.now) - (self.delivery_started_at || Time.now)).to_f
  end

  def count
    self.deliveries_count.to_i + self.errors_count.to_i
  end

  def sendings_per_second
    (sending_time > 0) ? (count.to_f / sending_time).round(2) : 0
  end

  def update_stats!
    if sending?
      self.delivery_started_at ||= live_send_outs.first(:order => "created_at ASC").try(:created_at)
      self.deliveries_count      = live_send_outs.where("finished_at IS NOT NULL").count
      self.errors_count          = live_send_outs.with_state(:failed).count
      if progress_percent >= 100
        self.delivery_ended_at   = live_send_outs.first(:order => "finished_at DESC").try(:finished_at)
        self.finish! #(end_time)
      end
      self.save!
    end
  end

  #-------------------------------------------------------------------------------------------------------------------------
   private
   def set_recipients_count
    self.recipients_count = recipients.count
   end

   def _send_test!
     self.test_recipient_emails_array.each do |test_recipient_email|
       self.test_send_outs.create!(:email => test_recipient_email.strip)
     end
     self.finish!
   end

   def _send_live!
     #TODO uses batches?
     self.recipients.each do |live_recipient|
       self.live_send_outs.create!(:recipient => live_recipient)
     end
    self.update_attribute(:recipients_count, self.live_send_outs.count) #TODO what if stopped??
   end

   def _resume_live!
     #self.update_attributes(:delivery_started_at => Time.now)
     self.live_send_outs.with_state(:stopped).map(&:resume!)
   end

   def _stop!
     self.live_send_outs.with_state(:sheduled).update_all(:state => 'stopped')
     self.finish!
     #self.live_send_outs.with_state(:sheduled).map(&:stop!) #TODO use magice mysql here
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
#  state               :string(255)     default("finished")
#  status              :integer(4)      not null, default(0)
#  subject             :string(255)
#  created_at          :datetime
#  deliver_at          :datetime
#  delivery_ended_at   :datetime
#  delivery_started_at :datetime
#  updated_at          :datetime
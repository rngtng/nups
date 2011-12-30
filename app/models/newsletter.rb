class Newsletter < ActiveRecord::Base
  QUEUE = :nups_newsletter
  HEADER_ID = "X-MA-Id"

  belongs_to :account

  has_many :recipients,  :through => :account, :conditions => { 'recipients.state' => :confirmed }
  has_many :attachments, :class_name => 'Asset'

  # http://stackoverflow.com/questions/738906/rails-dependent-and-delete
  has_many :send_outs,   :dependent => :delete_all #send_out has no dependency, speed it up
  has_many :live_send_outs
  has_many :test_send_outs

  scope :with_account, lambda { |account|  account ? where(:account_id => account.id) : {} }

  validates :account_id, :presence => true
  validates :subject,    :presence => true

  before_create :set_recipients_count

  ########################################################################################################################

  state_machine :initial => :new do
    event :send_test do
      transition :new     => :pre_testing
      transition :tested  => :pre_testing
    end

    event :send_live do
      transition :tested  => :pre_sending
      transition :stopped => :pre_sending
    end

    event :process do
      transition :pre_testing  => :testing
      transition :pre_sending => :sending
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

    after_transition all => :pre_testing do |me, transition|
      Resque.enqueue(me.class, me.id, "_send_test!", transition.args[0])
    end

    after_transition :tested => :pre_sending do |me|
      if me.deliver_at && me.deliver_at > Time.now
        Resque.enqueue_at(me.deliver_at, me.class, me.id, "_send_live!")
      else
        Resque.enqueue(me.class, me.id, "_send_live!")
      end
    end

    after_transition :stopped => :pre_sending do |me|
      Resque.enqueue(me.class, me.id, "_resume_live!")
    end

     before_transition :pre_sending => :sending do |me|
       me.recipients_count = me.live_send_outs.count #TODO what if stopped??
     end

    before_transition :sending => :finished do |me|
      me.delivery_ended_at = me.live_send_outs.first(:select => "finished_at", :order => "finished_at DESC").try(:finished_at)
    end

    after_transition all => :stopping do |me|
      Resque.enqueue(me.class, me.id, "_stop!")
    end
  end

  ########################################################################################################################

  def self.queue
    QUEUE
  end

  def self.perform(id, action, email = nil)
    self.find(id).send(action, email)
  end

  ########################################################################################################################

  def route
    [self.account, self]
  end

  def attachment_ids=(attachment_ids)
    self.attachments.clear
    attachment_ids.each do |attachment_id|
      if attachment_id.present? && (asset = account.assets.find_by_id(attachment_id))
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

  def progress_percent
    return 0 if self.recipients_count.to_i < 1
    (100 * count / self.recipients_count).round
  end

  #How long did it take to send newsletter
  def sending_time
    ((self.delivery_ended_at || Time.now) - (self.delivery_started_at || Time.now)).to_f.round(2)
  end

  def count
    self.deliveries_count.to_i + self.fails_count.to_i
  end

  def finishs_count
    self.deliveries_count.to_i - self.bounces_count.to_i - self.reads_count.to_i
  end

  def sendings_per_second
    (sending_time > 0) ? (count.to_f / sending_time).round(2) : 0
  end

  def update_stats!
    if pre_sending? || sending?
      n.delivery_started_at ||= n.live_send_outs.first(:order => "created_at ASC").try(:created_at)
      n.deliveries_count      = n.live_send_outs.where("finished_at IS NOT NULL").count
      n.fails_count           = n.live_send_outs.with_state(:failed).count
    end

    if done?
      self.finish!
    end

    if finished?
      self.bounces_count = live_send_outs.with_state(:bounced).count
      self.reads_count = live_send_outs.with_state(:read).count
    end
    self.save!
  end

  def done?
    (sending? && self.live_send_outs.with_state(:sheduled).count == 0) ||
    (testing? && self.test_send_outs.with_state(:sheduled).count == 0)
  end
  #-------------------------------------------------------------------------------------------------------------------------
   private
   def set_recipients_count
    self.recipients_count = recipients.count
   end

   def _send_test!(email = nil)
     account.test_recipient_emails_array(email).each do |test_recipient_email|
       self.test_send_outs.create!(:email => test_recipient_email.strip)
     end
     process!
   end

   def _send_live!(*args)
     self.recipients.each do |live_recipient|
       self.live_send_outs.create!(:recipient => live_recipient)
     end
     process!
   end

   def _resume_live!(*args)
     #self.update_attributes(:delivery_started_at => Time.now)
     self.live_send_outs.with_state(:stopped).map(&:resume!)
     process!
   end

   def _stop!(*args)
     self.live_send_outs.with_state(:sheduled).update_all(:state => 'stopped')
     finish!
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
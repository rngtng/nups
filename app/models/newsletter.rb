class Newsletter < ActiveRecord::Base

  STATUS = {
    :created   => 0,
    :running   => 2,
    :stopped   => 3,
    :scheduled => 4,
    :finished  => 5
  }

  TEST_MODE = 0
  LIVE_MODE = 1

  belongs_to :account
  has_many :recipients, :through => :account
  has_many :attachments, :class_name => 'Asset'

  scope :live, :conditions => { :mode => Newsletter::LIVE_MODE }
  scope :with_account, lambda { |account|  account ? where(:account_id => account.id) : {} }

  validates :account_id, :presence => true
  validates :subject, :presence => true
  validates :deliver_at, :presence => true

  with_options(:to => :account) do |account|
    %w(from host recipients test_recipients template_html template_text color has_html? has_text?).each do |attr|
      account.delegate attr
    end
  end

  @queue = :newsletter

  def self.perform(id, args = {})
    newsletter = Newsletter.find(id)
    return unless newsletter
    args = args.symbolize_keys rescue {}
    @test_emails = args[:test_emails] if args[:test_emails]
    newsletter.deliver!
  end

  ########################################################################################################################

  def route
    [self.account, self]
  end

  def attachment_ids=(attachment_ids)
    self.attachments = []
    attachment_ids.each do |attachment_id|
      asset = account.assets.where(:id => attachment_id).first
      self.attachments << asset if asset
    end
  end

  ########################################################################################################################

  def progress_percent
    deliveries  = deliveries_count || 0  #make sure we dont have nil
    errors      = errors_count || 0
    recipients_c = recipients_count || 0

    return 0 if recipients_c < 1
    (100 * (deliveries + errors) / recipients_c).round
  end

  #How long did it take to send newsletter
  def sending_time
    return 0 unless self.delivery_started_at
    time = self.delivery_ended_at? && !running? ? self.delivery_ended_at : Time.now
    (time - self.delivery_started_at).to_i
  end

  def deliveries_per_second
    return 0 if sending_time == 0
    return deliveries_count.to_f / sending_time.to_f
  end

  ########################################################################################################################

  def live?
    self.mode == LIVE_MODE
  end

  def test?
    self.mode != LIVE_MODE
  end

  def finished_live?
    test? && live?
  end

  def finished_test?
    test? && finished?
  end

  def human_status
    STATUS.each do |key, value|
      return key if value == self.status
    end
  end

  def human_mode
    test? ? "TEST" : "LIVE"
  end

  #fetches all status questions: finished?, running? etc
  def method_missing(m, *args)
    sym = m.to_s.delete('?').to_sym
    return status == STATUS[sym] if Newsletter::STATUS.include?( sym )
    super(m, *args)
  end

  ##############################################################################################

  #set status the scheduled to prevent newsletter is scheduled twice
  def schedule!(given_mode = TEST_MODE)
    self.reload
    throw :scheduled if self.scheduled?
    throw :running if self.running?
    #rest data if last run was a finished test
    if self.finished_test?
      self.delivery_ended_at = nil
      self.recipients_count  = 0
      self.last_sent_id = 0
    end
    self.status = STATUS[:scheduled]
    self.mode = given_mode
    self.recipients_count = recipients_all.count unless self.stopped?
    self.save!
  end

  #set status the scheduled to prevent newsletter is scheduled twice
  def unschedule!
    self.reload
    throw :running if self.running?
    throw :not_scheduled unless self.scheduled?
    self.status = STATUS[:created]
    self.mode = TEST_MODE
    self.save!
  end

  def deliver!(runs = nil)
    self.reload
    throw :not_scheduled unless self.scheduled?
    throw :running if running?
    #TODO check dirty update here...
    self.status = STATUS[:running]
    self.delivery_started_at = Time.now
    self.deliveries_count    = 0
    self.errors_count        = 0
    self.update_only( :status, :deliveries_count, :errors_count, :delivery_started_at)
    log("#{self.id} started")
    @exceptions = {}

    method = live? ? :find_each : :each
    recipients_all.send(method) do |recipient|
      send_to!(recipient)
      runs -= 1 if runs
      self.reload if (self.deliveries_count % 100) == 0 #reload only after 100 sendings
      stop! if runs && runs < 1
      break if stopped?
    end

    self.reload
    self.status = STATUS[:finished] if running? #status may could be stopped
    self.delivery_ended_at = Time.now
    self.update_only( :status, :delivery_ended_at )
  end

  def async_deliver!(args = {})
    Resque.enqueue(Newsletter, self.id, args)
    true
  rescue
    false
  end

  def stop!
     self.reload
     throw :not_running unless running?
     self.status = STATUS[:stopped]
     self.update_only(:status)
     log("#{self.id} stopped")
  end

  protected
  def recipients_all
    return recipients.greater_than(self.last_sent_id) if live?
    test_recipients(@test_emails)
  end

  def send_to!(recipient)
    NewsletterMailer.issue(self, recipient).deliver
    log("#{self.id} send to #{recipient.email} (#{recipient.id})")
    self.last_sent_id = recipient.id if live?
    self.deliveries_count += 1
  #rescue  => exp
  #  self.errors_count += 1
  #  @exceptions ||= {}
  #  @exceptions[recipient] = exp
  ensure
    self.update_only(:deliveries_count, :last_sent_id, :errors_count)
  end

  def update_only(*attributes)
    query = attributes.map { |a|
      value = self.send(a)
      value = value.to_s(:db) if value.is_a?( Time )
      "#{a} = '#{value}'"
    }
    Newsletter.update_all( query.join(", "), :id => self.id)
  end

 def log(msg)
   msg = "##- #{'TEST' if self.test?} NEWSLETTER #{msg}"
   #puts msg
   logger.info(msg)
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
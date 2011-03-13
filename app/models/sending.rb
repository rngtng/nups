class Sending < ActiveRecord::Base
  @queue = QUEUE = :nups_sending

  belongs_to :newsletter

  with_options(:presence => true) do |present|
    present.validates :newsletter_id
    present.validates :recipients_count
    present.validates :start_at
  end

  #validation, there can be only one sendingery with STATUS_NEW - no_paralell_sendings
  validate do |me|
    unless (newsletter.sendings.scheduled_or_running - Array(me)).empty?
      errors.add(:base, "Another sending already exists with state '#{sending.state}'")
    end
  end

  ########################################################################################################################

  state_machine :initial => :scheduled do
    event :start do
      transition :scheduled => :running
    end

    event :stop do
      transition :running => :stopped
      transition :scheduled => :stopped
    end

    event :finish do
      transition :running => :finished
    end

    ####

    before_transition :scheduled => :running do |me|
      me.start_at = Time.now
    end

    before_transition :running => [:stopped, :finished] do |me|
      me.finished_at = Time.now
      me.newsletter.finish!
    end

    after_transition :scheduled => :running do |me, transition|
       me.send :after_start, :reload_after => 100
    end
  end

  ########################################################################################################################

  before_validation :set_recipients_count, :set_start_at
  after_create  :async_start!

  scope :scheduled_or_running, :conditions => { :state => [:scheduled, :running] }
  scope :stopped_or_finished,  :conditions => { :state => [:stopped, :finished] }, :order => "updated_at DESC"
  scope :finished, :conditions => { :state => [:finished] }

  def self.perform(id, args = {})
    if sending = Sending.find(id)
      sending.start!
    end
  end

  ########################################################################################################################

  def progress_percent
    return 0 if self.recipients_count < 1
    (100 * self.count / self.recipients_count).round
  end

  #How long did it take to send newsletter
  def sending_time
    return 0 if state?(:scheduled)
    ((self.finished_at || Time.now) - self.start_at).to_f
  end

  def count
    self.oks + self.fails
  end

  def sendings_per_second
    return 0 if sending_time < 1
    return self.oks.to_f / sending_time
  end

  ########################################################################################################################

  def recipients
    []
  end

  ########################################################################################################################

  private
  def async_start!
    Resque.enqueue(Sending, self.id) #, args
  end

  def after_start(opts = {})
    reload_after = opts.delete(:reload_after) || 100

    self.recipients.find_each do |recipient|
      send_to!(recipient)
      break if (self.count % reload_after) == 0 && self.reload.stopped?
    end
    self.finish!
  end

  def set_recipients_count
    self.recipients_count = recipients.count
  end

  def set_start_at
    self.start_at ||= Time.now
  end

  def send_to!(recipient)
    NewsletterMailer.issue(self, recipient).deliver
  end

  # def update_only(todo_attributes = {})
  #   self.attributes = todo_attributes
  #   Newsletter.update_all(todo_attributes, :id => self.id)
  # end
end


# == Schema Info
#
# Table name: sendings
#
#  id               :integer(4)      not null, primary key
#  last_id          :integer(4)      not null, default(0)
#  newsletter_id    :integer(4)
#  fails            :integer(4)      not null, default(0)
#  oks              :integer(4)      not null, default(0)
#  recipients_count :integer(4)
#  state            :string(255)
#  type             :string(255)
#  created_at       :datetime
#  finished_at      :datetime
#  start_at         :datetime
#  updated_at       :datetime
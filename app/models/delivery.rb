class Delivery < ActiveRecord::Base
  @queue = QUEUE = :nups_delivery

  belongs_to :newsletter

  with_options(:presence => true) do |present|
    present.validates :newsletter_id
    present.validates :recipients_count
    present.validates :start_at
  end

  #validation, there can be only one delivery with STATUS_NEW - no_paralell_deliveries
  validate do |delivery|
    if nl = delivery.newsletter || Newsletter.find(delivery.newsletter_id)
      return true unless nl.delivery
      errors.add(:base, "Another delivery already exists with state '#{nl.delivery.state}'")
    end
    
  end

  ########################################################################################################################

  state_machine :initial => :scheduled do
    event :start do
      transition :scheduled => :running
    end

    event :stop do
      transition :running => :stopped
    end

    event :finish do
      transition :running => :finished
    end
  end

  ########################################################################################################################

  before_validation :set_recipients_count, :set_start_at
  after_create  :async_start!

  scope :current, :conditions => { :state => [:scheduled, :running] }

  def self.perform(id, args = {})
    if delivery = Delivery.find(id)
      args = args.symbolize_keys rescue {}
      delivery.start!(args)
    end
  end

  ########################################################################################################################

  def progress_percent
    return 0 if recipients_count < 1
    (100 * deliveries / recipients_count).round
  end

  #How long did it take to send newsletter
  def sending_time
    return 0 unless self.start_at
    time = (self.ended_at? && !running?) ? self.ended_at : Time.now
    (time - self.start_at).to_i
  end

  def deliveries
    self.oks + self.fails
  end

  def deliveries_per_second
    return 0 if sending_time == 0
    return oks.to_f / sending_time.to_f
  end

  ########################################################################################################################
  # def scheduled?(reload = false)
  #   self.reload if reload
  #   self.status == Status::SCHEDULED
  # end
  #
  # def running?(reload = false)
  #   self.reload if reload
  #   self.status == Status::RUNNING
  # end
  #
  # def stopped?(reload = false)
  #   self.reload if reload
  #   self.status == Status::STOPPED
  # end
  #
  # def finished?(reload = false)
  #   self.reload if reload
  #   self.status == Status::FINISHED
  # end
  ########################################################################################################################

  def start!(reload_after = 100)
    # check if sheduled?
    self.update_only :status => 'running', :start_at => Time.now

    recipients.find_each do |recipient|
      self.send_to!(recipient)
      break if self.stopped?( (self.deliveries % reload_after) == 0 )
    end
    self.update_only :status => 'finished', :finished_at => Time.now
  end

  def stop!
    return if finished?(true)
    self.update_only :status => 'stopped', :finished_at => Time.now
    #log("#{self.id} stopped")
  end

  def send_to!(recipient)
    self.newsletter.send_to!(recipient)
  end

  ########################################################################################################################

  def recipients
    []
  end

  # #fetches all status questions: finished?, running? etc
  # def method_missing(m, *args)
  #   sym = m.to_s.delete('?').to_sym
  #   return status == STATUS[sym] if Newsletter::STATUS.include?( sym )
  #   super(m, *args)
  # end

  private
  def async_start!
    Resque.enqueue(Delivery, self.id) #, args
  end

  def set_recipients_count
    self.recipients_count = recipients.count
  end

  def set_start_at
    self.start_at ||= Time.now
  end

  def update_only(todo_attributes = {})
    self.attributes = todo_attributes
    Newsletter.update_all(todo_attributes, :id => self.id)
  end
end

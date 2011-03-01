class Delivery < ActiveRecord::Base

  QUEUE     = :nups_delivery

  module Status
    SCHEDULED = 'scheduled'
    RUNNING   = 'running'
    STOPPED   = 'stopped'
    FINISHED  = 'finished'
  end

  with_options(:presence => true) do |present|
    present.validates :newsletter_id
    present.validates :status, :inclusion => { :in => STATUS }

    present.validates :recipients
    present.validates :start_at
  end

  validates_uniqueness_of :status, :scope => :newsletter_id, :if => { |d| d.status.scheduled? || d.status.running? }

  #validation
  # there can be only one delivery with STATUS_NEW

  scope :current, :conditions => { :status => STATUS_NEW }

  belongs_to :newsletter

  after_save :async_start!

  @queue = QUEUE

  def self.perform(id, args = {})
    if delivery = Delivery.find(id)
      args = args.symbolize_keys rescue {}
      delivery.start!(args)
    end
  end

  ########################################################################################################################

  def progress_percent
    return 0 if recipients.to_i < 1
    (100 * (oks.to_i + errors.to_i) / recipients.to_i).round
  end

  #How long did it take to send newsletter
  def sending_time
    return 0 unless self.start_at
    time = self.ended_at? && !running? ? self.ended_at : Time.now
    (time - self.start_at).to_i
  end

  def deliveries_per_second
    return 0 if sending_time == 0
    return oks.to_f / sending_time.to_f
  end

  ########################################################################################################################
  def scheduled?(reload = false)
    self.reload if reload
    self.status == Status::SCHEDULED
  end

  def running?(reload = false)
    self.reload if reload
    self.status == Status::RUNNING
  end
  
  def stopped?(reload = false)
    self.reload if reload
    self.status == Status::STOPPED
  end
  
  def finished?(reload = false)
    self.reload if reload
    self.status == Status::FINISHED
  end    
  ########################################################################################################################

  def start!(reloads = 100)
    # check if sheduled?
    self.update_only :status => 'running', :start_at => Time.now

    recipients_all.find_each do |recipient|
      send_to!(recipient, reloads)
      self.reload if ((self.oks + self.errors) % reloads) == 0
      break if stopped?
    end
    self.update_only :status => 'finished', :finished_at => Time.now
  end

  def stop!
    # check if running?
    self.reload
    self.update_only :status => 'stopped', :finished_at => Time.now
    #log("#{self.id} stopped")
  end

  def send_to!(recipient)
    self.newsletter.send_to! recipient
  end

  ########################################################################################################################

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

  def update_only(todo_attributes = {})
    self.attributes = todo_attributes
    Newsletter.update_all(todo_attributes, :id => self.id)
  end
end

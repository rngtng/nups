class Newsletter < ActiveRecord::Base
  
  belongs_to :account
  has_many :recipients, :through => :account
  
  STATUS = {
    :created   => 0,
    :running   => 2,
    :stopped   => 3,
    :scheduled => 4,
    :finished  => 5
  }

  TEST_MODE = 0
  LIVE_MODE = 1
  
  scope :live, :conditions => { :mode => LIVE_MODE }
  

  def color
    "#FFFFFF"
  end
  
  def has_html?
    true
  end

  def has_text?
    true
  end  
  
  def template
    type.to_s.underscore == 'non_business_newsletter' ? 'new_newsletter' : type.to_s.underscore
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
    time = self.delivery_finished_at? && !running? ? self.delivery_finished_at : Time.now
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

  def dummy_user
    User.find_by_login( example_user_login ) || User.first
  end

  #fetches all status questions: finished?, running? etc
  def method_missing(m, *args)
    sym = m.to_s.delete('?').to_sym
    return status == STATUS[sym] if Newsletter::STATUS.include?( sym )
    super(m, *args)
  end
  
  ##############################################################################################

  def test_user_emails
    l = language || 'de'
    @test_users ||= UserSystem::CONFIG[:newsletter_test_recipients][l.to_sym]
  end

  def example_user_login
    @example_user_login ||= UserSystem::CONFIG[:newsletter_test_user]
  end

  ##############################################################################################

  #set status the scheduled to prevent newsletter is scheduled twice
  def schedule!(given_mode = TEST_MODE)
    self.reload
    throw :scheduled if self.scheduled?
    throw :running if self.running?
    #rest data if last run was a finished test
    if self.finished_test?
      self.deliveries_count      = 0
      self.delivery_finished_at  = nil
      self.recipients_count      = 0
      self.errors_count          = 0
    end
    self.status = STATUS[:scheduled]
    self.mode = given_mode
    self.recipients_count = recipients_size
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

  def deliver!( runs = nil)
    self.reload
    throw :not_scheduled unless self.scheduled?
    throw :running if running?
    self.status = STATUS[:running]
    self.delivery_started_at = Time.now
    self.update_only( :status, :delivery_started_at )
    logger.info("##- NEWSLETTER #{self.id} started")
    @exceptions = {}

    recipients_all do |recipient|
      send_to!( recipient )
      runs -= 1 if runs
      self.reload   if (self.deliveries_count % 100) == 0 #reload only after 100 sendings
      deliver_stop! if runs && runs < 1
      break if stopped?
    end

    self.reload
    self.status = STATUS[:finished] if running? #status may could be stopped
    self.delivery_finished_at = Time.now
    self.update_only( :status, :delivery_finished_at )
  end

  def deliver_stop!
     self.reload
     throw :not_running unless running?
     self.status = STATUS[:stopped]
     self.update_only( :status )
     logger.info("##- NEWSLETTER #{self.id} stopped")
  end

  protected
  def recipients_all( &block )
    return live_users.paginated_each( :conditions => [ "users.id > ?", self.last_suc_sent_id ], :per_page => 1000, :order => 'users.id', &block) if live?
    test_users.each( &block )
  end

  def recipients_size
    return live_users.count( :select => "users.id") if live?
    test_users.size
  end

  def send_to!(recipient)
    NewsletterMailer.issue(self, recipient).deliver
    logger.info("##- NEWSLETTER #{self.id} send to #{recipient.email} (#{recipient.id})")
    self.last_suc_sent_id = recipient.id if live?
    self.deliveries_count += 1
  rescue  => exp
    self.errors_count += 1
    @exceptions ||= {}
    @exceptions[recipient] = exp
  ensure
    self.update_only( :deliveries_count, :last_suc_sent_id, :errors_count )
  end

  def update_only(*attributes)
    query = attributes.map { |a|
      value = self.send(a)
      value = value.to_s(:db) if value.is_a?( Time )
      "#{a} = '#{value}'"
    }
    Newsletter.update_all( query.join(", "), :id => self.id)
  end

  #get test emails from config and a dummy user.
  def test_users
    test_user_emails.map do |email|
      returning( dummy_user ) do |dummy_user|
        dummy_user.email = email
      end
    end
  end 

end

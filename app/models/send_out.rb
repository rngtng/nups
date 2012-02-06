class SendOut < ActiveRecord::Base
  QUEUE = :nups_send_outs

  belongs_to :newsletter
  belongs_to :recipient

  validates :newsletter_id, :presence => true

  after_save :async_deliver!

  state_machine :initial => :sheduled do
    event :deliver do
      transition :sheduled => :delivering
    end

    event :resume do
      transition :stopped => :sheduled
    end

    event :stop do
      transition :sheduled => :stopped
    end

    event :finish do
      transition :delivering => :finished
    end

    event :failure do
      transition :delivering => :failed
    end

    event :read do
      transition :finished  => :read
      transition :read => :read
    end

    event :bounce do
      transition :finished  => :bounced
      transition :bounced => :bounced
    end

    after_transition :sheduled => :delivering do |me|
      begin
        me.issue.deliver
        me.finish!
      rescue Exception => e
        me.failure!(e)
      end
    end
  end

  ########################################################################################################################

  def self.queue
    QUEUE
  end

  def self.perform(id)
    with_state(:sheduled).find_by_id(id, :include => [:newsletter, :recipient]).try(:deliver!)
  end

  def issue
    @issue ||= NewsletterMailer.issue(self.newsletter, self.recipient, self.id).tap do |issue|
      issue.header[Newsletter::HEADER_ID] = issue_id
    end
  end

  def issue_id #likely overwritten by subclasses
    ["ma", self.id].join('-')
  end

  private
  def async_deliver!
    if sheduled?
      Resque.enqueue(self.class, self.id)
    end
  end
end

# == Schema Information
#
# Table name: send_outs
#
#  id            :integer(4)      not null, primary key
#  recipient_id  :integer(4)
#  newsletter_id :integer(4)
#  type          :string(255)
#  state         :string(255)
#  email         :string(255)
#  error_message :text
#  created_at    :datetime
#  updated_at    :datetime
#  finished_at   :datetime
#

#  updated_at    :datetime

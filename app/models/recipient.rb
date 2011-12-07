class Recipient < ActiveRecord::Base

  SEARCH_COLUMNS = %w(email first_name last_name)

  belongs_to :account

  has_many :newsletters, :through => :account
  has_many :send_outs, :dependent => :destroy
  has_many :live_send_outs

  before_create :generate_confirm_code

  scope :greater_than, lambda { |recipient_id|  {:conditions => [ "recipients.id > ?", recipient_id ] } }
  scope :search, lambda { |search| search.blank? ? {} : {:conditions => SEARCH_COLUMNS.map { |column| "#{column} LIKE '%#{search}%'" }.join(' OR ') } }
  scope :confirmed, :conditions => { :state => :confirmed}

  validates :account_id, :presence => true
  validates :email, :presence => true, :uniqueness => {:scope => :account_id}, :email_format => true

  StateMachine::Machine.ignore_method_conflicts = true #to enable #delete
  state_machine :initial => :pending do
    event :confirm do
      transition :pending => :confirmed
    end

    event :bounce do
      transition any => :bounced
    end

    event :disable do
      transition any => :disabled
    end

    event :delete do
      transition any => :deleted
    end
  end

  alias_method :force_destroy, :destroy
  def destroy
    self.delete!
    self
  end

  def update_stats!
    self.deliveries_count = live_send_outs.with_states(:finished, :failed, :bounced, :read).count
    self.bounces_count    = live_send_outs.with_state(:bounced).count + self.bounces.to_s.split("\n").size
    self.failed_count     = live_send_outs.with_state(:failed).count
    self.reads_count      = live_send_outs.with_state(:read).count
    self.save!
  end

  private
  def generate_confirm_code
    self.confirm_code = SecureRandom.hex(8)
  end
end

# == Schema Info
#
# Table name: recipients
#
#  id               :integer(4)      not null, primary key
#  account_id       :integer(4)
#  bounces          :text            not null, default("")
#  bounces_count    :integer(4)      not null, default(0)
#  deliveries_count :integer(4)      not null, default(0)
#  email            :string(255)
#  failed_count     :integer(4)      not null, default(0)
#  first_name       :string(255)
#  gender           :string(255)
#  last_name        :string(255)
#  created_at       :datetime
#  updated_at       :datetime
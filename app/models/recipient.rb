class Recipient < ActiveRecord::Base

  SEARCH_COLUMNS = %w(email first_name last_name)

  belongs_to :account

  attr_accessible :gender, :first_name, :last_name, :email
  attr_accessible :account, :state, :gender, :first_name, :last_name, :email, :as => :test

  has_many :newsletters, :through => :account
  has_many :live_send_outs

  scope :greater_than, lambda { |recipient_id|  {:conditions => [ "recipients.id > ?", recipient_id ] } }
  scope :search, lambda { |search| search.blank? ? {} : {:conditions => SEARCH_COLUMNS.map { |column| "#{column} LIKE '%#{search}%'" }.join(' OR ') } }
  scope :confirmed, :conditions => { :state => :confirmed}

  validates :account_id, :presence => true
  validates :email, :presence => true, :uniqueness => {:scope => :account_id}, :email_format => true
  validates :confirm_code, :presence => true, :uniqueness => true, :on => :create

  StateMachine::Machine.ignore_method_conflicts = true #to enable #delete
  state_machine :initial => :pending do
    event :pending do
      transition :pending => :pending
      transition :deleted => :pending
    end

    event :confirm do
      transition :pending => :confirmed
      transition :confirmed => :confirmed
      transition :deleted => :confirmed
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

  def self.find_or_build_by(attrs)
    where(attrs).first || new(attrs)
  end

  alias_method :force_destroy, :destroy
  def destroy
    self.delete!
    self
  end

  def update_stats!
    self.deliveries_count = live_send_outs.with_states(:finished, :failed, :bounced, :read).count
    self.bounces_count    = live_send_outs.with_state(:bounced).count
    self.failed_count     = live_send_outs.with_state(:failed).count
    self.reads_count      = live_send_outs.with_state(:read).count
    self.save!
  end

  protected
  # in case we generate a duplicate confirm_code, reset code and regenerate a new one
  def run_validations!
    super.tap do
      if errors[:confirm_code].present?
        self.confirm_code = SecureRandom.hex(8)
        return valid? #re-run validation
      end
    end
  end

  #temporary will soon be gone
  def move_bounce_to_send_outs
    self.bounces.split("\n").each do |bounce|
      begin
        if ids = bounce.scan(/ma-(\d+)-(\d+)/).first
          account_id, newsletter_id = ids
          LiveSendOut.create!(:newsletter_id => newsletter_id, :state => 'bounced', :error_message => bounce, :recipient_id => self.id, :email => self.email)
        end
      rescue => e
        puts e.message
      end
    end
  end
end

# == Schema Info
#
# Table name: recipients
#
#  id               :integer(4)      not null, primary key
#  account_id       :integer(4)
#  bounces          :text
#  bounces_count    :integer(4)      not null, default(0)
#  confirm_code     :string(255)
#  deliveries_count :integer(4)      not null, default(0)
#  email            :string(255)
#  failed_count     :integer(4)      not null, default(0)
#  first_name       :string(255)
#  gender           :string(255)
#  last_name        :string(255)
#  reads_count      :integer(4)      not null, default(0)
#  state            :string(255)     default("pending")
#  created_at       :datetime
#  updated_at       :datetime
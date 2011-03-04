class Recipient < ActiveRecord::Base

  SEARCH_COLUMNS = %w(email first_name last_name)

  belongs_to :account

  has_many :newsletters, :through => :account

  has_many :deliveries, :dependent => :destroy
  has_many :failed_deliveries
  has_many :bounced_deliveries

  scope :greater_than, lambda { |recipient_id|  {:conditions => [ "recipients.id > ?", recipient_id ] } }
  scope :search, lambda { |search| search.blank? ? {} : {:conditions => SEARCH_COLUMNS.map { |column| "#{column} LIKE '%#{search}%'" }.join(' OR ') } }

  validates :account_id, :presence => true
  validates :email, :presence => true, :uniqueness => {:scope => :account_id}, :email_format => true

  def to_param
    self.id || 'test'
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
#  deliveries_count :integer(4)      not null, default(0)
#  email            :string(255)
#  fails            :text
#  fails_count      :string(255)
#  first_name       :string(255)
#  gender           :string(255)
#  last_name        :string(255)
#  created_at       :datetime
#  updated_at       :datetime
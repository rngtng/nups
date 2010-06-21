# == Schema Info
#
# Table name: recipients
#
#  id               :integer(4)      not null, primary key
#  account_id       :integer(4)
#  bounces          :text            not null, default("")
#  bounces_count    :integer(4)      not null
#  deliveries_count :integer(4)      not null
#  email            :string(255)
#  first_name       :string(255)
#  gender           :string(255)
#  last_name        :string(255)
#  created_at       :datetime
#  updated_at       :datetime

class Recipient < ActiveRecord::Base
  
  belongs_to :account
  
  has_many :newsletters, :through => :account
  
  scope :greater_than, lambda { |recipient_id|  {:conditions => [ "recipients.id > ?", recipient_id ] } }
  
  validates :account_id, :presence => true
  validates :email, :presence => true, :uniqueness => {:scope => :account_id}, :email_format => true
  
end
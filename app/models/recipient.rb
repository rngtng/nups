class Recipient < ActiveRecord::Base
  
  belongs_to :account
  
  has_many :newsletters, :through => :account
  
  scope :greater_than, lambda { |user_id|  {:conditions => [ "users.id > ?", self.user_id ], :order => 'users.id' } }
  
  validates :account_id, :presence => true
  validates :email, :presence => true, :uniqueness => {:scope => :account_id}, :email_format => true
  
end

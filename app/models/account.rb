class Account < ActiveRecord::Base
  
  belongs_to :user
  
  has_many :newsletters
  has_many :recipients
  
  validates_presence_of :user_id
end

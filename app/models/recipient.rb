class Recipient < ActiveRecord::Base
  
  belongs_to :account
  
  has_many :newsletters, :through => :account
  
end

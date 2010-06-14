class Account < ActiveRecord::Base
  
  belongs_to :user
  
  has_many :newsletters
  has_many :recipients
  
  validates_presence_of :user_id
  
  def test_users
    test_user_emails.map do |email|
      returning( User.new ) do |dummy_user|
        dummy_user.email = email
      end
    end
  end 
  
  
end

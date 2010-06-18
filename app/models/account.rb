class Account < ActiveRecord::Base
   #TODO template
     
  belongs_to :user
  
  has_many :newsletters
  has_many :recipients
  
  validates_presence_of :user_id
  
  def test_users(additional_email = nil)
    (test_user_emails + Array(additional_email)).compact.map do |email|
      returning( recipients.first.clone ) do |dummy_user| #TODO test if clone or dup!?
        dummy_user.email = email
      end
    end
  end
  
end

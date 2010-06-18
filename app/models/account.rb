# == Schema Info
#
# Table name: accounts
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)
#  from            :string(255)
#  host            :string(255)
#  name            :string(255)
#  subject         :string(255)
#  test_recipients :text
#  created_at      :datetime
#  updated_at      :datetime

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
# == Schema Info
#
# Table name: accounts
#
#  id                    :integer(4)      not null, primary key
#  user_id               :integer(4)
#  from                  :string(255)
#  host                  :string(255)
#  name                  :string(255)
#  subject               :string(255)
#  template_html         :text
#  template_text         :text
#  test_recipient_emails :text
#  created_at            :datetime
#  updated_at            :datetime

class Account < ActiveRecord::Base
     
  belongs_to :user
  
  has_many :assets
  has_many :newsletters
  has_many :recipients
  
  validates_presence_of :user_id
  
  def test_recipients(additional_emails = nil)
    (test_recipient_emails_array + Array(additional_emails)).uniq.map do |email|
      dummy_user = recipients.new(:email => email)
      dummy_user.readonly!
      dummy_user.valid? ? dummy_user : nil
    end.compact
  end
  
  def test_recipient_emails_array
    @test_recipient_emails_array = test_recipient_emails.to_s.split(/,|;|\n|\t/).map(&:strip)
  end
end
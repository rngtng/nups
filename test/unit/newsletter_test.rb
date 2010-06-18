# == Schema Info
#
# Table name: newsletters
#
#  id                  :integer(4)      not null, primary key
#  account_id          :integer(4)
#  last_sent_id        :integer(4)      not null
#  attachemnts         :text
#  content             :text
#  deliveries_count    :integer(4)      not null
#  errors_count        :integer(4)      not null
#  mode                :integer(4)      not null
#  recipients_count    :integer(4)      not null
#  status              :integer(4)      not null
#  subject             :string(255)
#  created_at          :datetime
#  deliver_at          :datetime
#  delivery_ended_at   :datetime
#  delivery_started_at :datetime
#  updated_at          :datetime

require 'test_helper'

class NewsletterTest < ActiveSupport::TestCase

  setup do
    ActionMailer::Base.deliveries.clear
    @user = users(:biff)
  end
  
  test "find by account" do
    @newsletter = newsletters(:biff_newsletter)
    
    assert_equal Newsletter.with_account(@newsletter.account).first, @newsletter
  end
end
# == Schema Info
#
# Table name: newsletters
#
#  id                  :integer(4)      not null, primary key
#  account_id          :integer(4)
#  last_sent_id        :integer(4)
#  attachments         :text
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
  
  test "should sent to user" do
    @newsletter = newsletters(:biff_newsletter)
    assert_difference '@newsletter.deliveries_count' do
      @newsletter.send(:send_to!,@newsletter.recipients.first)
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test "deliver to test users" do
    @newsletter = newsletters(:biff_newsletter)
    count = @newsletter.test_recipients.count
    
    @newsletter.schedule!(Newsletter::TEST_MODE)
    
    assert @newsletter.test?
    assert @newsletter.scheduled?
    
    @newsletter.deliver!
    
    assert_equal count, @newsletter.deliveries_count
    assert_equal count, ActionMailer::Base.deliveries.size
  end  

  
  test "deliver to live users" do
    @newsletter = newsletters(:biff_newsletter)
    count = @newsletter.recipients.count
    
    @newsletter.schedule!(Newsletter::LIVE_MODE)
    
    assert @newsletter.live?
    assert @newsletter.scheduled?
    
    @newsletter.deliver!
    
    assert_equal count, @newsletter.deliveries_count
    assert_equal count, ActionMailer::Base.deliveries.size
  end  
  
  test "should not scheduled twice" do
    @newsletter = newsletters(:biff_newsletter)
    @newsletter.schedule!( Newsletter::LIVE_MODE )
    assert_throws :scheduled do
      @newsletter.schedule!( Newsletter::LIVE_MODE )
    end
  end

  test "should update_only" do
    @newsletter = newsletters(:biff_newsletter)
    @newsletter.delivery_started_at = @newsletter.delivery_ended_at = Time.now

    @newsletter.send(:update_only, :delivery_started_at)
    @newsletter.reload
    assert @newsletter.delivery_started_at != @newsletter.delivery_ended_at
  end  
end
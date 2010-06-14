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

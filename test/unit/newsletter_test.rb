require 'test_helper'

class NewsletterTest < ActiveSupport::TestCase

  setup do
    ActionMailer::Base.deliveries.clear
    @user = users(:biff)
  end
  
  test "the truth" do
    assert true
  end
end

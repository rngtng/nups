require 'test_helper'

class NewsletterMailerTest < ActionMailer::TestCase
  
  setup do
    @newsletter = newsletters(:biff_newsletter)
  end
  
  test "body should include content" do
    @newsletter.content = "TEST"
    nl = NewsletterMailer.issue(@newsletter, @newsletter.recipients.first)
    
    assert_equal "TEST", nl.parts[0].body.decoded
  end

  test "body should include template AND content" do
    @newsletter.content = "TEST"
    @newsletter.account.template_html = "<html><body><%= content %></body></html>"
    @newsletter.account.template_text = "HEADER <%= content %>"
    
    nl = NewsletterMailer.issue(@newsletter, @newsletter.recipients.first)
    
    assert_equal "<html><body>TEST</body></html>", nl.parts[0].body.decoded
    assert_equal "HEADER TEST", nl.parts[1].body.decoded
  end

end

require 'test_helper'

class NewsletterMailerTest < ActionMailer::TestCase
  
  setup do
    @newsletter = newsletters(:biff_newsletter)
    asset = @newsletter.attachments.first
    asset.attachment = fixture_file_upload('Example.jpg', 'image/jpeg')
    asset.save!
  end
  
  test "body should include content" do
    @newsletter.content = "TEST"
    nl = NewsletterMailer.issue(@newsletter, @newsletter.recipients.first)
    
    assert_equal "TEST", html(nl)
  end

  test "body should include template AND content" do
    @newsletter.content = "TEST"
    @newsletter.account.template_html = "<html><body><%= content %></body></html>"
    @newsletter.account.template_text = "HEADER <%= content %>"
    
    nl = NewsletterMailer.issue(@newsletter, @newsletter.recipients.first)
    
    assert_equal "<html><body>TEST</body></html>", html(nl)
    assert_equal "HEADER TEST", text(nl)
  end

  test "body should include recipient email" do
    @newsletter.account.template_html = "<%= recipient.email %>"
    @newsletter.account.template_text = "<%= newsletter.subject %>"
    
    recipient = @newsletter.recipients.first
    
    nl = NewsletterMailer.issue(@newsletter, recipient)
    
    assert_equal recipient.email, html(nl)
    assert_equal @newsletter.subject, text(nl)
  end
  
  private
  def html(nl)
    nl.parts[1].body.decoded
  end

  def text(nl)
    nl.parts[0].body.decoded
  end

end

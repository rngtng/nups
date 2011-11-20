require 'spec_helper'

describe NewsletterMailer do
  fixtures :all

  let(:newsletter) { newsletters(:biff_newsletter) }
  let(:asset) {
    asset = newsletter.attachments.first
    asset.attachment = fixture_file_upload('Example.jpg', 'image/jpeg')
    asset.save!
  }

  describe "body" do
    it "should include content" do
      newsletter.update_attribute(:content, "TEST")

      nl = NewsletterMailer.issue(newsletter, newsletter.recipients.first)

      nl.html_part.body.decoded.should == "TEST"
    end

    it "should include template AND content" do
      newsletter.update_attribute(:content, "TEST")
      newsletter.account.update_attribute(:template_html, "<html><body><%= content %></body></html>")

      nl = NewsletterMailer.issue(newsletter, newsletter.recipients.first)

      nl.html_part.body.decoded.should == "<html><body>TEST</body></html>"
      nl.text_part.body.decoded.should == ""
    end

    it "should include recipient email" do
      newsletter.account.update_attribute(:template_html, "<%= recipient.email %>")

      recipient = newsletter.recipients.first

      nl = NewsletterMailer.issue(newsletter, recipient)

      nl.html_part.body.decoded.should == recipient.email
      nl.text_part.body.decoded.should == ""
    end
  end

end

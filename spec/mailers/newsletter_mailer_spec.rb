require 'spec_helper'

describe NewsletterMailer do
  fixtures :all

  let(:newsletter) { newsletters(:biff_newsletter) }
  let(:asset) {
    asset = newsletter.attachments.first
    asset.attachment = fixture_file_upload('Example.jpg', 'image/jpeg')
    asset.save!
  }

  context "body" do
    it "should include content" do
      newsletter.update_attribute(:content, "TEST")

      nl = NewsletterMailer.issue(newsletter, newsletter.recipients.first)

      html(nl).should == "TEST"
    end

    it "should include template AND content" do
      newsletter.update_attribute(:content, "TEST")
      newsletter.account.update_attribute(:template_html, "<html><body><%= content %></body></html>")
      newsletter.account.update_attribute(:template_text, "HEADER <%= content %>")

      nl = NewsletterMailer.issue(newsletter, newsletter.recipients.first)

      html(nl).should == "<html><body>TEST</body></html>"
      text(nl).should == "HEADER TEST"
    end

    it "should include recipient email" do
      newsletter.account.update_attribute(:template_html, "<%= recipient.email %>")
      newsletter.account.update_attribute(:template_text, "<%= newsletter.subject %>")

      recipient = newsletter.recipients.first

      nl = NewsletterMailer.issue(newsletter, recipient)

      html(nl).should == recipient.email
      text(nl).should == newsletter.subject
    end

    def html(nl)
      nl.parts[1].body.decoded
    end

    def text(nl)
      nl.parts[0].body.decoded
    end
  end

end

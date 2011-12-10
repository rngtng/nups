require 'spec_helper'

describe NewsletterMailer do
  fixtures :all

  let(:newsletter) { newsletters(:biff_newsletter) }
  let(:recipient) { newsletter.recipients.first }
  let(:issue) { NewsletterMailer.issue(newsletter, recipient) }
  let(:content) { newsletter.content }
  let(:html_body) { issue.html_part.body.decoded }
  let(:text_body) { issue.text_part.body.decoded  }

  #TODO add asset test
  # let(:asset) {
  #   asset = newsletter.attachments.first
  #   asset.attachment = fixture_file_upload('Example.jpg', 'image/jpeg')
  #   asset.save!
  # }

  #TODO add more local var test

  describe "body" do
    context "from default template" do
      it "includes content for HTML" do
        html_body.should include(content)
      end

      it "includes tracking code" do
        html_body.should include("/#{recipient.id}/0.gif")
      end

      it "includes content for TEXT" do
        text_body.should include(content)
      end
    end

    context "from empty template" do
      it "includes content for HTML" do
        newsletter.account.update_attribute(:template_html, "")
        html_body.should include(content)
      end

      it "includes content for TEXT" do
        newsletter.account.update_attribute(:template_text, "")
        text_body.should include(content)
      end
    end

    context "from custom template" do
      it "includes template AND content for HTML" do
        newsletter.account.update_attribute(:template_html, "<html><body><%= content %></body></html>")
        html_body.should == "<html><body>#{content}</body></html>"
      end

      it "includes template AND content for Text" do
        newsletter.account.update_attribute(:template_text, "<%= content %>")
        text_body.should == content
      end
    end

    context "from custom auto_link template" do
      let(:url) { "http://www.example.tld/Ausgabe_2011_49.pdf" }

      before do
        newsletter.account.update_attribute(:template_html, "<%= auto_link(content) %>")
      end

      it "adds link html" do
        newsletter.update_attribute(:content, url)
        html_body.should == "<a href=\"#{url}\">#{url}</a>"
      end

      it "does not double add link" do
        newsletter.update_attribute(:content, "<a href=\"#{url}\">#{url}</a>")
        html_body.should == "<a href=\"#{url}\">#{url}</a>"
      end
    end
  end

end

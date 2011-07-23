require 'spec_helper'

describe Newsletter do
  fixtures :all

  let(:newsletter) { newsletters(:biff_newsletter) }
  let(:account) { newsletter.account }

  describe "#recipients_count" do
    it "should be set on create" do
      new_newsletter = account.newsletters.create!(:subject => "Test")
      new_newsletter.recipients_count.should == new_newsletter.recipients.count
    end
  end

  describe "#with_account" do
    it "should find right newsletter" do
      Newsletter.with_account(account).first.should == newsletter
    end
  end

  context "without StateMachine" do
    describe "#send" do
      it "should create" do
        expect do
          newsletter.send("_send_live!")
        end.to change(LiveSendOut, :count).by(2)
      end

      it "updates recipients count" do
        newsletter.recipients_count = 0
        expect do
          newsletter.send("_send_live!")
        end.to change(newsletter, :recipients_count).by(2)
      end
    end

    describe "#stop/resume" do
      before do
        newsletter.stub('finish!').and_return(true)
        newsletter.send("_send_live!")
      end

      it "should stop" do
        expect do
          expect do
            newsletter.send("_stop!")
          end.to change(LiveSendOut.with_state(:sheduled), :count).by(-2)
        end.to change(LiveSendOut.with_state(:stopped), :count).by(2)
      end

      it "should resume" do
        newsletter.send("_stop!")

        expect do
          expect do
            newsletter.send("_resume_live!")
          end.to change(LiveSendOut.with_state(:sheduled), :count).by(2)
        end.to change(LiveSendOut.with_state(:stopped), :count).by(-2)
      end
    end
  end

  describe "#send" do
    shared_examples_for "sending to recipients" do
      let(:klass){ TestSendOut }
      let(:method){ "send_test!" }

      it "should send mail" do
        expect do
          with_resque do
            newsletter.send(method)
          end
        end.to change(ActionMailer::Base.deliveries, :size).by(2)
      end

      it "should create sendouts" do
        expect do
          with_resque do
            newsletter.send(method)
          end
        end.to change(klass.with_state(:finished), :count).by(2)
      end
    end

    context "test" do
      it "should have users" do
        newsletter.test_recipient_emails_array.count.should == 2
      end

      it_should_behave_like "sending to recipients"
    end

    context "live" do
      it "should have users" do
        newsletter.recipients.count.should == 2
      end

      it_should_behave_like "sending to recipients" do
        let(:klass){ LiveSendOut }
        let(:method){ "send_live!" }
      end
    end

    context "state machine" do
      it "should not scheduled twice" do
        newsletter.send_live!
        lambda do
          newsletter.send_live!
        end.should raise_error
      end
    end
  end

  describe "#template" do
    it "returns account value" do
      account.template_html = "test"
      newsletter.template.should == account.template_html
    end

    it "returns default value when nil" do
      account.template_html = nil
      newsletter.template.should == "<%= content %>"
    end

    it "returns default value when empty" do
      account.template_html = " "
      newsletter.template.should == "<%= content %>"
    end
  end

  describe "#attachments" do
    before do
      @newsletter = newsletters(:biff_newsletter)
      @newsletter.attachment_ids = [assets(:two), assets(:three)].map(&:id)
      @newsletter.save!
      @newsletter.reload
    end

    it "updates attachments :one" do
      assets(:one).reload.newsletter_id.should be_nil
    end

    it "updates attachments :two" do
      assets(:two).reload.newsletter_id.should == @newsletter.id
    end

    it "updates attachments :two" do
      assets(:three).reload.newsletter_id.should == @newsletter.id
    end

    it "updates attachments" do
      @newsletter.attachments.size.should == 2
    end

    it "doesn't assign empty blank ids" do
      account.should_not_receive(:assets)
      newsletter.update_attributes(:attachment_ids => [""])
    end
  end
end

# == Schema Info
#
# Table name: newsletters
#
#  id         :integer(4)      not null, primary key
#  account_id :integer(4)
#  content    :text
#  state      :string(255)
#  subject    :string(255)
#  created_at :datetime
#  updated_at :datetime
require 'spec_helper'

describe Newsletter do
  fixtures :all

  let(:newsletter) { newsletters(:biff_newsletter) }

  describe "#with_account" do
    it "should find right newsletter" do
      Newsletter.with_account(newsletter.account).first.should == newsletter
    end
  end

  describe "#send without StateMachine" do
    it "should create" do
      expect do
        newsletter.send("_send_live!")
      end.to change(LiveSendOut, :count).by(2)
    end

    it "should stop" do
      newsletter.send("_send_live!")

      expect do
        expect do
          newsletter.send("_stop!")
        end.to change(LiveSendOut.with_state(:sheduled), :count).by(-2)
      end.to change(LiveSendOut.with_state(:stopped), :count).by(2)
    end

    it "should resume" do
      newsletter.send("_send_live!")
      newsletter.send("_stop!")

      expect do
        expect do
          newsletter.send("_resume_live!")
        end.to change(LiveSendOut.with_state(:sheduled), :count).by(2)
      end.to change(LiveSendOut.with_state(:stopped), :count).by(-2)
    end
  end

  describe "#send" do
    context "test" do
      it "should have users" do
        newsletter.test_recipient_emails_array.count.should == 2
      end

      it "should deliver to users" do
        expect do
          expect do
            with_resque do
              newsletter.send_test!
            end
          end.to change(TestSendOut.with_state(:finished), :count).by(2)
        end.to change(ActionMailer::Base.deliveries, :size).by(2)
      end
    end

    context "live" do
      it "should have users" do
        newsletter.recipients.count.should == 2
      end

      it "should deliver to users" do
        expect do
          expect do
            with_resque do
              newsletter.send_live!
            end
          end.to change(LiveSendOut.with_state(:finished), :count).by(2)
        end.to change(ActionMailer::Base.deliveries, :size).by(2)
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

  describe "#attachments" do
    before do
      @newsletter = newsletters(:biff_newsletter)
      @newsletter.attachment_ids = [assets(:two), assets(:three)].map(&:id)
      @newsletter.save!
      @newsletter.reload
    end

    it "should update attachments :one" do
      assets(:one).reload.newsletter_id.should be_nil
    end

    it "should update attachments :two" do
      assets(:two).reload.newsletter_id.should == @newsletter.id
    end

    it "should update attachments :two" do
      assets(:three).reload.newsletter_id.should == @newsletter.id
    end

    it "should update attachments" do
      @newsletter.attachments.size.should == 2
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
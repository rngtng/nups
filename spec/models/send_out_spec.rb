require 'spec_helper'

describe SendOut do
  fixtures :all

  let(:newsletter) { newsletters(:biff_newsletter) }
  let(:live_send_out) { LiveSendOut.create!(:newsletter => newsletter, :recipient => newsletter.recipients.first) }
  let(:test_send_out) { TestSendOut.create!(:newsletter => newsletter, :email => "test@test.de") }

  context "#create" do
    describe LiveSendOut do
      it "should set email" do
        live_send_out.email.should == newsletter.recipients.first.email
      end

      it "should not allow multiple instances" do
        live_send_out
        lambda do
          LiveSendOut.create!(:newsletter => newsletter, :recipient => live_send_out.recipient)
        end.should raise_error
      end
    end

    it "should allow multiple instances of TestSendOut" do
      live_send_out
      lambda do
        TestSendOut.create!(:newsletter => newsletter, :email => "test@test.de")
      end.should_not raise_error
    end
  end

  context "#async_deliver!" do
    before do
      ResqueSpec.reset!
    end

    it "live should be scheduled after create" do
      LiveSendOut.should have_queued(live_send_out.id)
      TestSendOut.should_not have_queued(live_send_out.id)
    end

    it "test should be scheduled after create" do
      TestSendOut.should have_queued(test_send_out.id)
      LiveSendOut.should_not have_queued(test_send_out.id)
    end
  end

  describe "#deliver!" do
    before(:each) do
      ActionMailer::Base.deliveries.clear
    end

    it "should send out test sending" do
      expect do
        test_send_out.deliver!
      end.to change(ActionMailer::Base.deliveries, :size).by(1)
    end

    it "should send out live sending" do
      expect do
        live_send_out.deliver!
      end.to change(ActionMailer::Base.deliveries, :size).by(1)
    end

    it "should change state to finished on success" do
      live_send_out.deliver!
      live_send_out.state.should == 'finished'
    end

    it "should change state to failed on failure" do
      live_send_out.issue.stub(:deliver).and_raise
      live_send_out.deliver!
      live_send_out.state.should == 'failed'
    end
  end

end

# == Schema Info
#
# Table name: send_outs
#
#  id            :integer(4)      not null, primary key
#  newsletter_id :integer(4)
#  recipient_id  :integer(4)
#  email         :string(255)
#  error_code    :string(255)
#  error_message :text
#  state         :string(255)
#  type          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
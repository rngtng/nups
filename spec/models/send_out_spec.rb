require 'spec_helper'

describe SendOut do
  fixtures :all

  let(:recipient) { newsletter.recipients.first }
  let(:newsletter) { newsletters(:biff_newsletter) }
  let(:live_send_out) { LiveSendOut.create!(:newsletter => newsletter, :recipient => recipient) }
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

    context "TestSendOut" do
      it "should send out test sending" do
        expect do
          test_send_out.deliver!
        end.to change(ActionMailer::Base.deliveries, :size).by(1)
      end

      it "changes state to finished on success" do
        expect do
          test_send_out.deliver!
        end.not_to change { Recipient.count }
      end
    end

    context "LiveSendOut" do
      it "should send out live sending" do
        expect do
          live_send_out.deliver!
        end.to change(ActionMailer::Base.deliveries, :size).by(1)
      end

      it "changes state to finished on success" do
        expect do
          live_send_out.deliver!
        end.to change { live_send_out.reload.state }.from('sheduled').to('finished')
      end

      it "set finished_at" do
        expect do
          live_send_out.deliver!
        end.to change { live_send_out.reload.finished_at }.from(nil)
      end

      it "increases recipients deliveries_count" do
        expect do
          live_send_out.deliver!
        end.to change { recipient.reload.deliveries_count }.by(1)
      end

      it "should change state to failed on failure" do
        live_send_out.issue.stub(:deliver).and_raise
        expect do
          live_send_out.deliver!
        end.to change { live_send_out.reload.state }.from('sheduled').to('failed')
      end

      it "increases recipients failed_count" do
        live_send_out.issue.stub(:deliver).and_raise
        expect do
          live_send_out.deliver!
        end.to change { recipient.reload.failed_count }.by(1)
      end
    end
  end

  describe "#read!" do
    it "changes from finished to read" do
      live_send_out.update_attributes(:state => 'finished')
      expect do
        live_send_out.read!
      end.to change { live_send_out.reload.state }.from('finished').to('read')
    end

    it "does not change from read to read" do
      live_send_out.update_attributes(:state => 'read')
      expect do
        live_send_out.read!
      end.to_not change { live_send_out.reload.state }.from('read')
    end

    it "increases recipients reads_count" do
      live_send_out.update_attributes(:state => 'finished')
      expect do
        live_send_out.read!
      end.to change { recipient.reload.reads_count }.by(1)
    end
  end

  describe "#bounce!" do
    it "changes from finished to read" do
      live_send_out.update_attributes(:state => 'finished')
      expect do
        live_send_out.bounce!
      end.to change { live_send_out.reload.state }.from('finished').to('bounced')
    end

    it "does not change from read to read" do
      live_send_out.update_attributes(:state => 'bounced')
      expect do
        live_send_out.bounce!
      end.to_not change { live_send_out.reload.state }.from('bounced')
    end

    it "increases recipients bounces_count" do
      live_send_out.update_attributes(:state => 'finished')
      expect do
        live_send_out.bounce!
      end.to change { recipient.reload.bounces_count }.by(1)
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
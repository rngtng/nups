require 'spec_helper'

describe Newsletter do
  fixtures :all

  let(:newsletter) { newsletters(:biff_newsletter) }
  let(:account) { newsletter.account }

  describe "#with_account" do
    it "should find right newsletter" do
      Newsletter.with_account(account).first.should == newsletter
    end
  end

  describe "#new" do
    context "created from draft" do
      subject { account.newsletters.create(:draft => newsletter) }

      %w(subject content).each do |method|
        it "copies #{method}" do
          subject.send(method).should == newsletter.send(method)
        end
      end
    end
  end

  describe "#draft" do
    let(:new_newsletter) { Newsletter.new(:draft => newsletter) }

    it "copies subject" do
      new_newsletter.subject.should == newsletter.subject
    end

    it "copies content" do
      new_newsletter.content.should == newsletter.content
    end
  end

  describe "#recipients_count" do
    let(:new_newsletter) { account.newsletters.create!(:subject => "Test") }

    it "should be set on create" do
      new_newsletter.recipients_count.should == new_newsletter.recipients.count
    end
  end

  context "without StateMachine" do

    describe "#_send_test!" do
      before do
        newsletter.update_attribute("state", "pre_testing")
      end

      it "creates TestSendOuts" do
        expect do
          newsletter.send("_send_test!")
        end.to change(TestSendOut, :count).by(2)
      end

      it "uniq test" do
        expect do
          newsletter.send("_send_test!", newsletter.account.test_recipient_emails_array.first)
        end.to change(TestSendOut, :count).by(2)
      end

      it "calls process!" do
        newsletter.should_receive(:process!)
        newsletter.send("_send_test!")
      end

      it "calls process!" do
        expect do
          newsletter.send("_send_test!")
        end.to change { newsletter.state }.from("pre_testing").to("testing")
      end

      it "creates TestSendOuts for extra email" do
        newsletter.send("_send_test!", "extra@email.de")
        newsletter.test_send_outs.map(&:email).should include("extra@email.de")
      end
    end

    describe "#_send_live!" do
      before do
        newsletter.update_attribute("state", "pre_sending")
      end

      it "creates LiveSendOuts" do
        expect do
          newsletter.send("_send_live!")
        end.to change(LiveSendOut, :count).by(2)
      end

      it "updates recipient count" do
        expect do
          newsletter.send("_send_live!")
        end.to change { newsletter.recipients_count }.from(0).to(2)
      end

      it "calls process!" do
        newsletter.should_receive(:process!)
        newsletter.send("_send_live!")
      end

      it "calls process!" do
        expect do
          newsletter.send("_send_live!")
        end.to change { newsletter.state }.from("pre_sending").to("sending")
      end
    end

    describe "#_stop!" do
      before do
        newsletter.update_attribute("state", "pre_sending")
        newsletter.send("_send_live!")
      end

      it "stopps" do
        expect do
          expect do
            newsletter.send("_stop!")
          end.to change(LiveSendOut.with_state(:sheduled), :count).by(-2)
        end.to change(LiveSendOut.with_state(:stopped), :count).by(2)
      end

      it "resumes" do
        newsletter.update_attribute("state", "stopping")
        newsletter.send("_stop!")
        newsletter.update_attribute("state", "pre_sending")

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
      let(:method){ :send_test }

      it "sends mail" do
        expect do
          with_resque do
            newsletter.fire_state_event(method)
          end
        end.to change(ActionMailer::Base.deliveries, :size).by(2)
      end

      it "creates sendouts" do
        expect do
          with_resque do
            newsletter.fire_state_event(method)
          end
        end.to change(klass.with_state(:finished), :count).by(2)
      end
    end

    context "test" do
      it "should have users" do
        newsletter.account.test_recipient_emails_array.count.should == 2
      end

      it_should_behave_like "sending to recipients"

      it "sends mail to custom email" do
        expect do
          with_resque do
            newsletter.send_test!("another@email.de")
          end
        end.to change(ActionMailer::Base.deliveries, :size).by(3)
      end
    end

    context "live" do
      it "should have users" do
        newsletter.recipients.count.should == 2
      end

      it_should_behave_like "sending to recipients" do
        let(:klass){ LiveSendOut }
        let(:method){ :send_live }
      end
    end

    context "state machine" do
      it "should not scheduled twice" do
        newsletter.send_live!
        expect do
          newsletter.send_live!
        end.to raise_error
      end
    end
  end

  describe "#attachments" do
    let(:newsletter) { newsletters(:biff_newsletter) }
    before do
      newsletter.attachment_ids = [assets(:two), assets(:three)].map(&:id)
      newsletter.save!
      #@newsletter.reload
    end

    it "updates attachments :one" do
      assets(:one).reload.newsletter_id.should be_nil
    end

    it "updates attachments :two" do
      assets(:two).reload.newsletter_id.should == newsletter.id
    end

    it "updates attachments :two" do
      assets(:three).reload.newsletter_id.should == newsletter.id
    end

    it "updates attachments" do
      newsletter.attachments.size.should == 2
    end

    it "doesn't assign empty blank ids" do
      account.should_not_receive(:assets)
      newsletter.update_attributes(:attachment_ids => [""])
    end
  end

  describe "#done?" do

    it "" do
      #sending", one schedule, one done -> not done
      #sending", no scheduled, two done -> done
      #newsletter.

      #newsletter.should be_done
    end
  end

  describe "#update_stats!" do
    context "test newsletter" do
       before do
         newsletter.update_attribute('state', 'testing')
      end

       it "calls finish" do
         expect do
           newsletter.update_stats!
         end.to change { newsletter.reload.state }.from('testing').to('tested')
       end
    end

    context "live newsletter" do
      before do
        newsletter.update_attributes(:state => 'sending')
        @send_out_first = newsletter.live_send_outs.create!(:recipient => newsletter.recipients.first)
        @send_out_last = newsletter.live_send_outs.create!(:recipient => newsletter.recipients.last)
      end

      context "sending" do
        let(:created_at) { 5.days.ago }

        it "updates delivery_started_at" do
          @send_out_first.update_attributes(:created_at => created_at)
          expect do
            newsletter.update_stats!
          end.to change { newsletter.delivery_started_at.to_i }.to(created_at.to_i)
        end

        it "doesn't change state" do
          expect do
            newsletter.update_stats!
          end.to_not change { newsletter.reload.state }.from('sending')
        end
      end

      context "finished" do
        let(:finished_at) { 2.days.ago }

        before do
          newsletter.update_attributes(:state => 'sending')
          @send_out_first.update_attributes(:state => 'finished', :finished_at => 3.days.ago)
          @send_out_last.update_attributes(:state => 'read', :finished_at => finished_at)
        end

        it "does not update delivery_started_at" do
          newsletter.update_attributes(:delivery_started_at => Time.now)
          expect do
            newsletter.update_stats!
          end.to_not change { newsletter.delivery_started_at }
        end

        it "finishes newsletter" do
          expect do
            newsletter.update_stats!
          end.to change { newsletter.reload.state }.from('sending').to('finished')
        end

        it "updates delivery_ended_at" do
          expect do
            newsletter.update_stats!
          end.to change { newsletter.reload.delivery_ended_at.to_i }.to(finished_at.to_i)
        end

        it "updates errors_count" do
          @send_out_last.update_attributes(:state => 'failed', :updated_at => finished_at)
          expect do
            newsletter.update_stats!
          end.to change { newsletter.fails_count }.by(1)
        end

        it "updates reads_count" do
          expect do
            newsletter.update_stats!
          end.to change { newsletter.reads_count }.by(1)
        end

        it "updates deliveries_count" do
          expect do
            newsletter.update_stats!
          end.to change { newsletter.deliveries_count }.by(2)
        end
      end
    end

  end
end

# == Schema Info
#
# Table name: newsletters
#
#  id                  :integer(4)      not null, primary key
#  account_id          :integer(4)
#  last_sent_id        :integer(4)
#  content             :text
#  deliveries_count    :integer(4)      not null, default(0)
#  errors_count        :integer(4)      not null, default(0)
#  mode                :integer(4)      not null, default(0)
#  recipients_count    :integer(4)      not null, default(0)
#  state               :string(255)     default("finished")
#  status              :integer(4)      not null, default(0)
#  subject             :string(255)
#  created_at          :datetime
#  deliver_at          :datetime
#  delivery_ended_at   :datetime
#  delivery_started_at :datetime
#  updated_at          :datetime
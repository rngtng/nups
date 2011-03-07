require 'spec_helper'

describe Sending do
  fixtures :all

  describe "#create" do
    before(:each) do
      @newsletter = newsletters(:biff_newsletter)
      @sending    = @newsletter.send_live!
    end

    it "should not allow multiple instances of state 'scheduled'" do
      lambda do
        @newsletter.send_live!
      end.should raise_error
    end

    it "should not allow multiple instances of state 'scheduled'" do
      @sending.update_attribute(:state, 'running')
      lambda do
        @newsletter.send_live!
      end.should raise_error
    end

    it "should allow multiple instances of state 'scheduled' and 'stopped'" do
      @sending.update_attribute(:state, 'stopped')
      lambda do
        @newsletter.reload.send_live!
      end.should_not raise_error
    end

    it "should allow multiple instances of state 'scheduled' and 'finished'" do
      @sending.update_attribute(:state, 'finished')
      lambda do
        @newsletter.reload.send_live!
      end.should_not raise_error
    end
  end

  context "#async_start!" do
    before do
      ResqueSpec.reset!
    end

    it "should be scheduled after create" do
      @newsletter = newsletters(:biff_newsletter)
      deliver = @newsletter.send_live!
      Sending.should have_queued(deliver.id)
    end
  end

  describe "#send_to!" do
    before(:each) do
      ActionMailer::Base.deliveries.clear
      @newsletter = newsletters(:biff_newsletter)
    end

    it "should send out test sending" do
      @sending = @newsletter.send_test!

      expect do
       @sending.send(:send_to!, @newsletter.recipients.first)
      end.to change(ActionMailer::Base.deliveries, :size).by(1)
    end

    it "should send out live sending" do
      @sending = @newsletter.send_live!

      expect do
        @sending.send(:send_to!, @newsletter.recipients.first)
      end.to change(ActionMailer::Base.deliveries, :size).by(1)
    end

  end

  describe "states" do
    before(:each) do
      @newsletter = newsletters(:biff_newsletter)
      @sending    = @newsletter.send_live!
      @sending.stub!(:after_start).and_return(true)
      @sending.start!
    end

    # after(:each) { back_to_1985 }

    it "should change state to running" do
      @sending.state.should == 'running'
      @sending.finished_at.should be_nil
    end

    it "should change state to stopped" do
      @sending.stop!

      @sending.state.should == 'stopped'
      @sending.finished_at.should_not be_nil
    end

    it "should change state to finished" do
      @sending.finish!
      @sending.state.should == 'finished'
      @sending.finished_at.should_not be_nil
    end

  end

  describe "#update_only" do
  end

  # test "should " do
  #   @sending = deliveries(:biff_sending)
  #
  #
  #   @newsletter.send(:update_only, :sending_started_at)
  #   @newsletter.reload
  #   assert @newsletter.sending_started_at != @newsletter.sending_ended_at
  # end

end


# == Schema Info
#
# Table name: sendings
#
#  id               :integer(4)      not null, primary key
#  last_id          :integer(4)      not null, default(0)
#  newsletter_id    :integer(4)
#  fails            :integer(4)      not null, default(0)
#  oks              :integer(4)      not null, default(0)
#  recipients_count :integer(4)
#  state            :string(255)
#  type             :string(255)
#  created_at       :datetime
#  finished_at      :datetime
#  start_at         :datetime
#  updated_at       :datetime
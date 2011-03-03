require 'spec_helper'

describe Sending do
  fixtures :all

  describe "#create" do
    before(:each) do
      @newsletter = newsletters(:biff_newsletter)
      @sending    = @newsletter.live_sendings.create!
    end

    it "should not allow multiple instances of state 'scheduled'" do
      lambda do
        @newsletter.live_deliveries.create!
      end.should raise_error
    end

    it "should not allow multiple instances of state 'scheduled'" do
      @sending.update_attribute(:state, 'running')
      lambda do
        @newsletter.live_deliveries.create!
      end.should raise_error
    end

    it "should allow multiple instances of state 'scheduled' and 'stopped'" do
      @sending.update_attribute(:state, 'stopped')
      lambda do
        @newsletter.reload.live_deliveries.create!
      end.should_not raise_error
    end

    it "should allow multiple instances of state 'scheduled' and 'finished'" do
      @sending.update_attribute(:state, 'finished')
      lambda do
        @newsletter.reload.live_deliveries.create!
      end.should_not raise_error
    end
    
    it "should be scheduled after create" do
      
    end
  end

  describe "#send_to!" do
    before(:each) do
      ActionMailer::Base.deliveries.clear
      @newsletter = newsletters(:biff_newsletter)

    end

    it "should send out test sending" do
      @sending = @newsletter.test_deliveries.create!

      expect do
       @sending.send(:send_to!, @newsletter.recipients.first)
      end.to change(ActionMailer::Base.deliveries, :size).by(1)
    end

    it "should send out live sending" do
      @sending = @newsletter.live_deliveries.create!

      expect do
        @sending.send(:send_to!, @newsletter.recipients.first)
      end.to change(ActionMailer::Base.deliveries, :size).by(1)
    end

  end

  describe "states" do
    before(:each) do
      @newsletter = newsletters(:biff_newsletter)
      @sending   = @newsletter.live_deliveries.create!
      @sending.start!
    end

    after(:each) { back_to_1985 }

    it "should change state to running" do
      @sending.reload.state.should == 'running'
      @sending.finished_at.should be_nil
    end

    it "should change state to stopped" do
      @sending.stop!

      @sending.reload.state.should == 'stopped'
      @sending.finished_at.should_not be_nil
    end

    it "should change state to finished" do
      @sending.finish!
      @sending.reload.state.should == 'finished'
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

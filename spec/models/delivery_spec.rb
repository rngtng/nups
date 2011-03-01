require 'spec_helper'

describe Delivery do
  fixtures :all

  describe "#create" do
    before(:each) do
      @newsletter = newsletters(:biff_newsletter)
      @delivery   = @newsletter.live_deliveries.create!
    end

    it "should not allow multiple instances of state 'scheduled'" do
      lambda do
        @newsletter.live_deliveries.create!
      end.should raise_error
    end

    it "should not allow multiple instances of state 'scheduled'" do
      @delivery.update_attribute(:state, 'running')
      lambda do
        @newsletter.live_deliveries.create!
      end.should raise_error
    end

    it "should allow multiple instances of state 'scheduled' and 'stopped'" do
      @delivery.update_attribute(:state, 'stopped')
      lambda do
        @newsletter.reload.live_deliveries.create!
      end.should_not raise_error
    end

    it "should allow multiple instances of state 'scheduled' and 'finished'" do
      @delivery.update_attribute(:state, 'finished')
      lambda do
        @newsletter.reload.live_deliveries.create!
      end.should_not raise_error
    end
  end

  describe "#update_only" do
  end

  # test "should " do
  #   @delivery = deliveries(:biff_delivery)
  #
  #
  #   @newsletter.send(:update_only, :delivery_started_at)
  #   @newsletter.reload
  #   assert @newsletter.delivery_started_at != @newsletter.delivery_ended_at
  # end

end

# == Schema Info
#
# Table name: deliveries
#
#  id               :integer(4)      not null, primary key
#  last_id          :integer(4)      not null, default(0)
#  newsletter_id    :integer(4)
#  bounces          :integer(4)      not null, default(0)
#  fails            :integer(4)      not null, default(0)
#  oks              :integer(4)      not null, default(0)
#  recipients_count :integer(4)
#  state            :string(255)
#  type             :string(255)
#  created_at       :datetime
#  finished_at      :datetime
#  start_at         :datetime
#  updated_at       :datetime
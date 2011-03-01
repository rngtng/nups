require 'test_helper'

class NewsletterTest < ActiveSupport::TestCase

  setup do
    ActionMailer::Base.deliveries.clear
    @user = users(:biff)
  end

  test "find by account" do
    @newsletter = newsletters(:biff_newsletter)

    assert_equal Newsletter.with_account(@newsletter.account).first, @newsletter
  end

  test "should sent to user" do
    @newsletter = newsletters(:biff_newsletter)
    assert_difference '@newsletter.deliveries_count' do
      @newsletter.send(:send_to!, @newsletter.recipients.first)
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test "deliver to test users" do
    @newsletter = newsletters(:biff_newsletter)
    count = @newsletter.test_recipients.count
    assert count > 0

    @newsletter.deliver_test!

    assert @newsletter.delivery.is_a? TestDelivery
    assert @newsletter.delivery.scheduled?

    @newsletter.deliver!

    assert_equal count, ActionMailer::Base.deliveries.size
  end

  test "deliver to live users" do
    @newsletter = newsletters(:biff_newsletter)
    count = @newsletter.recipients.count

    @newsletter.deliver_live!

    assert @newsletter.delivery.is_a? LiveDelivery

    assert_equal count, @newsletter.delivery.oks
    assert_equal count, ActionMailer::Base.deliveries.size
  end

  test "stop of deliver to live users should resume live" do
    @newsletter = newsletters(:biff_newsletter)
    count = @newsletter.recipients.count

    @newsletter.schedule!(Newsletter::LIVE_MODE)

    assert @newsletter.live?
    assert @newsletter.scheduled?

    stop_after = 1
    @newsletter.deliver!(stop_after)

    assert @newsletter.live?
    assert @newsletter.stopped?
    assert_equal stop_after, @newsletter.deliveries_count
    assert_equal stop_after, ActionMailer::Base.deliveries.size

    @newsletter.schedule!(Newsletter::LIVE_MODE)
    @newsletter.deliver!

    assert_equal 1, @newsletter.deliveries_count
    assert_equal count, ActionMailer::Base.deliveries.size
  end

  test "should not scheduled twice" do
    @newsletter = newsletters(:biff_newsletter)
    @newsletter.schedule!( Newsletter::LIVE_MODE )
    assert_throws :scheduled do
      @newsletter.schedule!( Newsletter::LIVE_MODE )
    end
  end

  test "should update_only" do
    @newsletter = newsletters(:biff_newsletter)
    @newsletter.delivery_started_at = @newsletter.delivery_ended_at = Time.now

    @newsletter.send(:update_only, :delivery_started_at)
    @newsletter.reload
    assert @newsletter.delivery_started_at != @newsletter.delivery_ended_at
  end

  test "should update attachments" do
    @newsletter = newsletters(:biff_newsletter)
    assert_equal @newsletter.id, assets(:one).reload.newsletter_id
    assert_equal 1, @newsletter.attachments.size

    @newsletter.attachment_ids = [assets(:two), assets(:three)].map(&:id)
    @newsletter.save!

    @newsletter.reload

    assert_equal nil, assets(:one).reload.newsletter_id
    assert_equal @newsletter.id, assets(:two).reload.newsletter_id
    assert_equal @newsletter.id, assets(:three).reload.newsletter_id
    assert_equal 2, @newsletter.attachments.size
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
#  status              :integer(4)      not null, default(0)
#  subject             :string(255)
#  created_at          :datetime
#  deliver_at          :datetime
#  delivery_ended_at   :datetime
#  delivery_started_at :datetime
#  updated_at          :datetime
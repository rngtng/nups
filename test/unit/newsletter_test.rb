require 'test_helper'

class NewsletterTest < ActiveSupport::TestCase

  test "stop of deliver to live users should resume live" do
    @newsletter = newsletters(:biff_newsletter)
    count = @newsletter.recipients.count

    @newsletter.send_live!

    assert @newsletter.stopped?
    assert_equal stop_after, @newsletter.deliveries_count
    assert_equal stop_after, ActionMailer::Base.deliveries.size

    @newsletter.send_live!

    assert_equal 1, @newsletter.deliveries_count
    assert_equal count, ActionMailer::Base.deliveries.size
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
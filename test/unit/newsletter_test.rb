require 'test_helper'

class NewsletterTest < ActiveSupport::TestCase

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
#  id         :integer(4)      not null, primary key
#  account_id :integer(4)
#  content    :text
#  state      :string(255)
#  subject    :string(255)
#  created_at :datetime
#  updated_at :datetime
require 'test_helper'

class AssetTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Info
#
# Table name: assets
#
#  id                      :integer(4)      not null, primary key
#  account_id              :integer(4)
#  newsletter_id           :integer(4)
#  user_id                 :integer(4)
#  attachment_content_type :string(255)
#  attachment_file_name    :string(255)
#  attachment_file_size    :string(255)
#  created_at              :datetime
#  updated_at              :datetime
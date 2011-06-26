require 'test_helper'

class BounceTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Info
#
# Table name: bounces
#
#  id         :integer(4)      not null, primary key
#  account_id :integer(4)
#  user_id    :integer(4)
#  body       :text
#  from       :string(255)
#  header     :text
#  raw        :text
#  subject    :string(255)
#  created_at :datetime
#  send_at    :datetime
#  updated_at :datetime
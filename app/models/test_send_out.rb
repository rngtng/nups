class TestSendOut < SendOut

  def recipient
    @recipient ||= Recipient.new(:email => email)
  end

  def issue_id
    ["ma", self.id, "test"].join('-')
  end

  def issue
    super.tap do |issue|
      issue.subject = "TEST: #{issue.subject}"
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
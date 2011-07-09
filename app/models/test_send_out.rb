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

class TestSendOut < SendOut

  state_machine :initial => :sheduled do
    before_transition :delivering => :finished do |me|
      me.finished_at = Time.now
    end

    before_transition :delivering => :failed do |me, transition|
      me.error_message = transition.args[0]
    end
  end

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

# == Schema Information
#
# Table name: send_outs
#
#  id            :integer(4)      not null, primary key
#  recipient_id  :integer(4)
#  newsletter_id :integer(4)
#  type          :string(255)
#  state         :string(255)
#  email         :string(255)
#  error_message :text
#  created_at    :datetime
#  updated_at    :datetime
#  finished_at   :datetime
#
# Indexes
#
#  index_send_outs_on_newsletter_id_and_type                   (newsletter_id,type)
#  index_send_outs_on_newsletter_id_and_type_and_recipient_id  (newsletter_id,type,recipient_id)
#

#  updated_at    :datetime

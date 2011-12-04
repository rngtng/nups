class LiveSendOut < SendOut

  validates :recipient_id, :presence => true, :uniqueness => {:scope => [:newsletter_id, :type]}, :on => :create

  before_validation :set_email, :on => :create

  def issue_id
    ["ma", self.id, self.recipient_id].join('-')
  end

  private
  def set_email
    self.email = recipient.email
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
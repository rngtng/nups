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

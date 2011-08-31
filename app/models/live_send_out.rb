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


=begin

def move_to_recipient
  if recipient
    rec = Array(mail.final_recipient).split(";")[1].try(:strip)
    unless recipient.bounces.to_s.include?(mail_id)
      recipient.bounces_count += 1
      recipient.bounces = "#{mail.date.strftime("%Y-%m-%d")} #{mail_id} <#{rec}>: #{mail.error_status} #{mail.diagnostic_code}\n#{recipient.bounces}"
      recipient.save!
    end
    self.raw = nil
  end
end


=end

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
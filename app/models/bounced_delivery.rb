class BouncedDelivery < Delivery
  belongs_to :recipient

end

# == Schema Info
#
# Table name: deliveries
#
#  id           :integer(4)      not null, primary key
#  recipient_id :integer(4)
#  sending_id   :integer(4)
#  code         :string(255)
#  message      :text
#  type         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
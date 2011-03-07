class Delivery < ActiveRecord::Base

  belongs_to :sending

end

########################################################################################################################
# def scheduled?(reload = false)
#   self.reload if reload
#   self.status == Status::SCHEDULED
# end
#
# def running?(reload = false)
#   self.reload if reload
#   self.status == Status::RUNNING
# end
#
# def stopped?(reload = false)
#   self.reload if reload
#   self.status == Status::STOPPED
# end
#
# def finished?(reload = false)
#   self.reload if reload
#   self.status == Status::FINISHED
# end

# #fetches all status questions: finished?, running? etc
# def method_missing(m, *args)
#   sym = m.to_s.delete('?').to_sym
#   return status == STATUS[sym] if Newsletter::STATUS.include?( sym )
#   super(m, *args)
# end
########################################################################################################################

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
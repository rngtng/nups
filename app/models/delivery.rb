class Delivery < ActiveRecord::Base
end


class FailedDelivery < Delivery
end

class BouncedDelivery < Delivery
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
#  id               :integer(4)      not null, primary key
#  last_id          :integer(4)      not null, default(0)
#  newsletter_id    :integer(4)
#  bounces          :integer(4)      not null, default(0)
#  fails            :integer(4)      not null, default(0)
#  oks              :integer(4)      not null, default(0)
#  recipients_count :integer(4)
#  state            :string(255)
#  type             :string(255)
#  created_at       :datetime
#  finished_at      :datetime
#  start_at         :datetime
#  updated_at       :datetime
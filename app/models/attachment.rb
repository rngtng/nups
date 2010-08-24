#require 'carrierwave/orm/activerecord'

class Attachment < ActiveRecord::Base
  
  belongs_to :newsletter
  belongs_to :user
  
  #mount_uploader :name, AttachmentUploader
  
  validates :name, :presence => true
  #validates :newsletter_id, :presence => true
  validates :user_id, :presence => true
  
end

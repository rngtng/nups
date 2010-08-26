class Asset < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :account
  belongs_to :newsletter
  
  has_attached_file :attachment
  
  validates_attachment_presence :attachment

  validates :user_id, :presence => true
  validates :account_id, :presence => true
  
  def name
    attachment_file_name
  end

  def size
    attachment_file_size
  end
  
  def path
    attachment.path
  end
end

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

  def content_type
    attachment.content_type
  end
end

# == Schema Info
#
# Table name: assets
#
#  id                      :integer(4)      not null, primary key
#  account_id              :integer(4)
#  newsletter_id           :integer(4)
#  user_id                 :integer(4)
#  attachment_content_type :string(255)
#  attachment_file_name    :string(255)
#  attachment_file_size    :string(255)
#  created_at              :datetime
#  updated_at              :datetime
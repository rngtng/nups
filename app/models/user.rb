# == Schema Info
#
# Table name: users
#
#  id                   :integer(4)      not null, primary key
#  admin                :boolean(1)
#  confirmation_token   :string(255)
#  current_sign_in_ip   :string(255)
#  email                :string(255)     not null, default("")
#  encrypted_password   :string(128)     not null, default("")
#  last_sign_in_ip      :string(255)
#  password_salt        :string(255)     not null, default("")
#  remember_token       :string(255)
#  reset_password_token :string(255)
#  sign_in_count        :integer(4)      default(0)
#  confirmation_sent_at :datetime
#  confirmed_at         :datetime
#  created_at           :datetime
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  remember_created_at  :datetime
#  updated_at           :datetime

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :admin, :password, :password_confirmation
  
  has_many :accounts
  has_many :newsletters, :through => :accounts

end
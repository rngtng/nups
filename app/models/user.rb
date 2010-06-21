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
#  username             :string(255)
#  confirmation_sent_at :datetime
#  confirmed_at         :datetime
#  created_at           :datetime
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  remember_created_at  :datetime
#  updated_at           :datetime

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable, :confirmable,
  devise :database_authenticatable, :registerable, 
         :recoverable, :rememberable, :trackable, :validatable

  devise :database_authenticatable, :authentication_keys => [:username]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :admin, :password, :password_confirmation
  
  validate :username, :presence => true, :uniqueness => true
  
  has_many :accounts
  has_many :newsletters, :through => :accounts

  #http://wiki.github.com/plataformatec/devise/log-in-using-login-or-mail
  def self.find_for_database_authentication(conditions)
     conditions = ["username = ? or email = ?", conditions[authentication_keys.first], conditions[authentication_keys.first]]
     # raise StandardError, conditions.inspect
     super
   end
end
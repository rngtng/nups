class Domain < ActiveRecord::Base
  belongs_to :user

  def main_url
    "https://sslsites.de/kundenmenue/uebersicht.php?rekm_login=#{username}&rekm_password=#{password}"
  end

  def ftp_url
    "https://sslsites.de/kundenmenue/ftp.php?rekm_login=#{username}&rekm_password=#{password}"
  end

end

# == Schema Information
#
# Table name: domains
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  name       :string(255)
#  number     :string(255)
#  username   :string(255)
#  password   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

#  updated_at :datetime

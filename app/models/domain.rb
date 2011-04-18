class Domain < ActiveRecord::Base
  belongs_to :user

  def email_url
    "https://sslsites.de/kundenmenue/email.php?rekm_login=#{username}&rekm_password=#{password}&dn=#{number}"
  end

  def ftp_url
    "https://sslsites.de/kundenmenue/ftp.php?rekm_login=#{username}&rekm_password=#{password}&dn=#{number}"
  end

end

class Domain < ActiveRecord::Base
  belongs_to :user

  def main_url
    "https://sslsites.de/kundenmenue/uebersicht.php?rekm_login=#{username}&rekm_password=#{password}"
  end

  def ftp_url
    "https://sslsites.de/kundenmenue/ftp.php?rekm_login=#{username}&rekm_password=#{password}"
  end

end

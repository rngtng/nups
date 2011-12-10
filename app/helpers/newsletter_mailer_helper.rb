module NewsletterMailerHelper
  def auto_link(content)
    Rinku.auto_link(content).html_safe
  end
end
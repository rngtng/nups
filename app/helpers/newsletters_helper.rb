module NewslettersHelper

  def pull_time
    Rails.env.test? ? 250 : 2000
  end
end


module NewslettersHelper

  def pull_time
    Rails.env.test? ? 400 : 2000
  end
end


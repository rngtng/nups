class NewsletterMailer < ActionMailer::Base
  default :from => "from@example.com"
  
  def newsletter( user )
    # vars go here
    # @user = user
    mail :to => user.email, :subject => "Test"
  end
end

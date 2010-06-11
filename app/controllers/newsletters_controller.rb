class NewslettersController < ApplicationController
  
  def load_newsletter
    @newsletter = current_user.newsletter.find(params[:id])
    render unless @newsletter
    
  end
  
end

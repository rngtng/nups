class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'
  
  before_filter :authenticate_user!
  
  def authenticate_admin!
    render_404 unless current_user.admin?
  end
  
  def render_404
    render :file => "public/404", :layout => false, :status => 404
  end
  
end

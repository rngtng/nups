class HomeController < ApplicationController
  
  def index
    render :layout => false
  end
    
  def menu
    @user = current_user
    @user = User.find(params[:user_id]) if params[:user_id] && current_user.admin?
    render :layout => false
  end

  def main
  end  
end

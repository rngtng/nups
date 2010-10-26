class HomeController < ApplicationNupsController

  def index
    render :layout => false
  end

  def top_menu
    render :layout => false
  end

  def menu
    @user = current_user
    @user = User.find(params[:user_id]) if params[:user_id] && current_user.admin?

    @users = current_user.admin? ? User.all : Array(@user)
    render :layout => false
  end

  def main
  end
end

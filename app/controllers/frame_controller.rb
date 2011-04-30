class FrameController < ApplicationNupsController
  def index
    @user = current_user
    @user = User.find(params[:user_id]) if params[:user_id] && current_user.admin?

    @users = current_user.admin? ? User.all : Array(@user)
  end
end

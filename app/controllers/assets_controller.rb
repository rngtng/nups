class AssetsController < ApplicationNupsController
  before_filter :load_user, :load_account

  def create
    @asset = @account.assets.create(:attachment => params[:file], :user_id => current_user.id, :newsletter_id => params[:newsletter_id])
    render @asset
  end

  private
  def load_user
    @user = current_user
    @user = User.find(params[:user_id]) if params[:user_id] && current_user.admin?
  end
end

class AttachmentsController < ApplicationController
  before_filter :load_user, :load_account
  
  def create
    @attachment = @newsletter.attachments.new(:name => params[:name])
    @attachment.file = params[:file]
    @attachment.save!
    render :nothing => true
  end

  private
  def load_user
    @user = current_user
    @user = User.find(params[:user_id]) if params[:user_id] && current_user.admin?
  end

  def load_account
    return if params[:account_id].blank?
    klass = current_user.admin? ? Account : current_user.accounts
    @account = klass.find_by_id(params[:account_id])
    render_403 unless @account
  end  

  # def load_newsletter
  #   return if params[:newsletter_id].blank?
  #   @newsletter = @account.newsletters.find_by_id(params[:newsletter_id])
  #   render_403 unless @newsletter
  # end 

end

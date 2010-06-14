class NewslettersController < ApplicationController
  
  before_filter :load_account
  
  

  private
  def load_account
    klass = current_user.admin? ? Account : current_user.accounts
    @account = klass.find(params[:account_id])
    render_404 unless @account
  end  
end

class SendOutsController < ApplicationController
  before_filter :load_account, :load_recipient

  def index
    @send_outs = @recipient.send_outs
    render :layout => !request.xhr?
  end

  private
  def load_account
    klass = current_user.admin? ? Account : current_user.accounts
    @account = klass.find_by_id(params[:account_id])
    render_404 unless @account
  end

  def load_recipient
    @recipient = @account.recipients.find_by_id(params[:recipient_id])
    render_404 unless @recipient
  end
end

class SendOutsController < ApplicationController
  before_filter :load_account, :load_recipient

  def index
    @send_outs = @recipient.send_outs
    render :layout => !request.xhr?
  end

  private
  def load_recipient
    @recipient = @account.recipients.find_by_id(params[:recipient_id])
    render_404 unless @recipient
  end
end

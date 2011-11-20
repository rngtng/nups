class Public::NewslettersController < ApplicationController

  def show
    if @send_out = LiveSendOut.find_by_recipient_id_and_id(params[:recipient_id], params[:send_out_id])
      @send_out.read!
      @issue = @send_out.issue
    else
      render_404
    end
  end
end

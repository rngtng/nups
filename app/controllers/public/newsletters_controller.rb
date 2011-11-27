class Public::NewslettersController < ApplicationController

  respond_to :html, :gif

  def show
    if @send_out = LiveSendOut.find_by_recipient_id_and_id(params[:recipient_id], params[:send_out_id])
      @send_out.read!
      @issue = @send_out.issue

      respond_with do |format|
        format.html
        # http://stackoverflow.com/questions/5228238/rails-how-to-send-an-image-from-a-controller
        format.gif { send_file "public/pixel.gif" }
      end
    else
      render_404
    end
  end

end

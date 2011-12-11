class Public::NewslettersController < ApplicationController

  respond_to :html, :gif

  def show
    image = params[:image] || 'pixel'

    if @send_out = LiveSendOut.find_by_recipient_id_and_id(params[:recipient_id], params[:send_out_id])
      @send_out.read!

      respond_with do |format|
        format.html do
          @issue = @send_out.issue
          @tracking = render_to_string :partial => "layouts/tracking"
          render :layout => false
        end
        # http://stackoverflow.com/questions/5228238/rails-how-to-send-an-image-from-a-controller
        format.gif { send_file "public/images/#{image}.gif" }
      end
    else

      respond_with do |format|
        format.html { render_404 }
        format.gif { send_file "public/images/#{image}.gif" }
      end
    end
  end
end

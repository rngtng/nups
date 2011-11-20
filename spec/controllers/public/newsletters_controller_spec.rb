require 'spec_helper'

describe Public::NewslettersController do
  fixtures :all

  let(:newsletter) { newsletters(:biff_newsletter) }
  let(:live_send_out) { LiveSendOut.create!(:newsletter => newsletter, :recipient => newsletter.recipients.first, :state => 'finished') }

  describe "#show" do
    it "finds sendout by id and recipient id" do
      get :show, :recipient_id => live_send_out.recipient_id, :send_out_id => live_send_out.id
      assigns(:send_out).should == live_send_out
    end

    context "with views" do
      #integrate_views

      it "returns sendout by id and recipient id" do
        get :show, :recipient_id => live_send_out.recipient_id, :send_out_id => live_send_out.id
        response.status.should == 200 #:success
      end

      it "returns sendout by id and recipient id" do
        get :show, :recipient_id => live_send_out.recipient_id, :send_out_id => 34
        response.status.should == 404 #:success
      end
    end
  end

end

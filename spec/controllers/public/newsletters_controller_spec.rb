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

    it "marks finsihed send_out as read" do
      expect do
        get :show, :recipient_id => live_send_out.recipient_id, :send_out_id => live_send_out.id
      end.to change { live_send_out.reload.state }.from('finished').to('read')
    end

    context "with views" do
      render_views

      context "format html" do
        it "returns sendout by id and recipient id" do
          get :show, :recipient_id => live_send_out.recipient_id, :send_out_id => live_send_out.id
          response.status.should == 200 #:success
        end

        it "returns sendout by id and recipient id" do
          get :show, :recipient_id => live_send_out.recipient_id, :send_out_id => 34
          response.status.should == 404
        end
      end

      context "format gif" do
        it "returns sendout by id and recipient id" do
          get :show, :recipient_id => live_send_out.recipient_id, :send_out_id => live_send_out.id, :format => 'gif'
          response.status.should == 200 #:success
        end

        it "returns sendout by id and recipient id" do
          get :show, :recipient_id => 0, :send_out_id => 0, :format => 'gif'
          response.body.should include('GIF89a')
        end

        it "body is image" do
          get :show, :recipient_id => live_send_out.recipient_id, :send_out_id => live_send_out.id, :format => 'gif'
          response.body.should include('GIF89a')
        end
      end

    end
  end

end

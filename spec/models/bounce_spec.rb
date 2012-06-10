require 'spec_helper'

describe Bounce do
  let(:bounce) { build(:bounce) }

  context "create" do
    it "gets enqueued" do
      new_bounce = create(:bounce, :raw => "example Email")
      Bounce.should have_queued(new_bounce.id)
    end
  end

  it "find mail id" do
    bounce.mail_id.should == "ma-14-87"
  end

  it "bounced" do
    bounce.mail.should be_bounced
  end

  describe "#process!" do
    before do
      bounce.process!
    end

    it "sets subject" do
      bounce.subject.should == 'Notificacion del estado del envio'
    end

    it "sets from" do
      bounce.from.should == 'postmaster@telecable.es'
    end

    it "sets error_status" do
      bounce.error_status.should == '5.1.1'
    end

    it "sets send_out_id" do
      bounce.send_out_id.should == 14
    end

    it "sets recipient_id" do
      bounce.recipient_id.should == 87
    end
  end

  context "send_out" do
    let(:send_out) { create(:live_send_out) }
    let(:newsletter) { send_out.newsletter }
    let(:recipient) { send_out.recipient }

    before do
      bounce.stub(:mail_id).and_return "ma-#{send_out.id}-#{recipient.id}"
      bounce.stub(:error_message).and_return "error"
    end

    it "changes send_out state" do
      expect do
        bounce.process!
      end.to change { send_out.reload.state }.from('finished').to('bounced')
    end

    it "adds error_message to send_out" do
      expect do
        bounce.process!
      end.to change { send_out.reload.error_message }.from(nil).to("error")
    end

    it "increases recipient bounces_count" do
      expect do
        bounce.process!
      end.to change { recipient.reload.bounces_count }.by(1)
    end

    # #dummy test to make sure fixture is right
    it "send_out has same account" do
      recipient.account.id.should == newsletter.account.id
    end
  end
end

# == Schema Information
#
# Table name: bounces
#
#  id           :integer(4)      not null, primary key
#  account_id   :integer(4)
#  recipient_id :integer(4)
#  from         :string(255)
#  subject      :string(255)
#  send_at      :datetime
#  header       :text
#  body         :text
#  raw          :text
#  created_at   :datetime
#  updated_at   :datetime
#  error_status :string(255)
#  send_out_id  :integer(4)
#

#  updated_at   :datetime

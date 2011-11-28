require 'spec_helper'

describe Bounce do
  fixtures :all

  let(:bounce) { bounces(:raw) }

  context "create" do
    it "gets enqueued" do
      new_bounce = Bounce.create!(:account => Account.first, :raw => "example Email")
      Bounce.should have_queued(new_bounce.id)
    end
  end

  context "old format" do
    let(:bounce) { bounces(:"raw-old") }

    it "find mail id" do
      bounce.mail_id.should == "ma-14-87-33228"
    end

    it "sets account_id" do
      bounce.process!
      bounce.account_id.should == 14
    end

    it "sets recipient_id" do
      bounce.process!
      bounce.recipient_id.should == 33228
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

end
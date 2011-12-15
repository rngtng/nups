require 'spec_helper'

describe ChartsHelper do
  fixtures :all

  let(:account) { accounts(:biff_account) }

  describe "newsletters_chart" do
    it "works" do
      puts helper.newsletters_chart(account.newsletters)
    end
  end

  describe "recipients_chart" do
    it "works" do
      puts helper.recipients_chart(account.recipients)
    end
  end
end

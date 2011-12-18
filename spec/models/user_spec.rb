require 'spec_helper'

describe User do

  it "create User with custom created_at" do
    create_date = 3.days.ago
    User.make!(:created_at => create_date).reload.created_at.to_i.should == create_date.to_i
  end

  it "create User with custom updated_at" do
    update_date = 3.days.ago
    User.make!(:updated_at => update_date).reload.updated_at.to_i.should == update_date.to_i
  end

  it "creates a user" do
    expect do
      Account.make!
    end.to change { User.count }
  end

  it "make a unsaved user" do
    a = Account.make
    puts a.inspect
    puts a.user.inspect
    # .should_not be_new_record
  end
    
  it "make a unsaved user" do
    a = Account.make!
    puts a.inspect
    puts a.user.inspect
#    .should_not be_new_record
  end

  it "make a unsaved user" do
    Account.make!.user.should_not be_new_record
  end

  it "not creates a user" do
    expect do
      Account.make
    end.to_not change { User.count }
  end

  it "make a unsaved user" do
    Account.make.user.should be_new_record
  end
end

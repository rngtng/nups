# encoding: UTF-8
require 'spec_helper'

describe 'recipients page' do
  fixtures :users, :accounts, :recipients

  let(:user) { users(:biff) }
  let(:account) { accounts(:biff_account) }
  let(:recipient) { recipients(:josh) }

  before do
    visit '/'
    fill_in 'user_username', :with => user.email
    fill_in 'user_password', :with => 'admin'
    click_on 'Login'
  end

  it 'show recipients' do
    visit account_recipients_path(account)

    page.should have_content('Empfänger')
  end

  it 'click edit', :js => true do
    visit account_recipients_path(account)
    #within("#recipient_#{recipient.id}") do
    find("#recipient_#{recipient.id} a.edit").click   #_on '<span>ändern</span>'
    #end
    page.should have_selector("#recipient_#{recipient.id}.edit")
  end

end
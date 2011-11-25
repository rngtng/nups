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

  it 'show recipients', :js => true do
    visit account_recipients_path(account)

    page.should have_content('Empfänger')

    within("#recipient-#{recipient.id}") do
      find("td.show").should be_visible
      find("td.edit").should_not be_visible
    end
  end

  it 'clicks edit, cancels and delete', :js => true do
    visit account_recipients_path(account)

    within("#recipient-#{recipient.id}") do
      find("a.edit").click

      find("td.show").should_not be_visible
      find("td.edit").should be_visible
      find("a.cancel").click
      #page.should_not have_selector("#recipient-#{recipient.id}.edit")

      find("td.show").should be_visible
      find("td.edit").should_not be_visible
      find("a.delete").click

      # http://stackoverflow.com/questions/2458632/how-to-test-a-confirm-dialog-with-cucumber
      page.driver.browser.switch_to.alert.accept
    end

    wait_until(10) do
      #page.should have_no_selector("#recipient-#{recipient.id}")
      page.find("#recipient-#{recipient.id}").should_not be_visible
    end

  end
end
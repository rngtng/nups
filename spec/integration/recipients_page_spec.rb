# encoding: UTF-8
require 'spec_helper'

describe 'recipients page' do
  fixtures :users, :accounts, :recipients

  let(:user) { users(:biff) }
  let(:account) { accounts(:biff_account) }
  let(:recipient) { recipients(:josh) }
  let(:recipient2) { recipients(:wonne) }

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

  it 'clicks edit, cancels and edits', :js => true do
    visit account_recipients_path(account)

    page.should have_no_selector("#recipient-#{recipient.id}.edit")

    within("#recipient-#{recipient.id}") do
      find("a.edit").click
      find("td.show").should_not be_visible
      find("td.edit").should be_visible

      find("a.cancel").click
      find("td.show").should be_visible
      find("td.edit").should_not be_visible

      find("a.edit").click
      find(".edit.first-name input").set('first-name')
      find(".edit.last-name input").set('last-name')
      find(".edit.email input").set('email@localhost.de')
      find("a.save").click
      sleep 1 #wait for request to finish
      Recipient.find_by_first_name_and_last_name_and_email('first-name', 'last-name', 'email@localhost.de').should_not be_nil
    end
  end

  it 'clicks delete', :js => true do
    visit account_recipients_path(account)

    page.should have_selector("#recipient-#{recipient.id}")
    page.should have_selector("#recipient-#{recipient2.id}")

    find("#recipient-#{recipient.id} a.delete").click
    # http://stackoverflow.com/questions/2458632/how-to-test-a-confirm-dialog-with-cucumber
    page.driver.browser.switch_to.alert.accept

    sleep 1
    page.should have_no_selector("#recipient-#{recipient.id}")
    page.should have_selector("#recipient-#{recipient2.id}")
  end
end
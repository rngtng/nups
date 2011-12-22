# encoding: UTF-8
require 'spec_helper'

describe 'recipients page' do
  fixtures :users, :accounts, :recipients, :newsletters

  let(:user) { users(:biff) }
  let(:account) { accounts(:biff_account) }
  let(:newsletter) { newsletters(:biff_newsletter) }
  let(:newsletter2) { newsletters(:biff_newsletter_two) }

  before do
    visit '/'
    fill_in 'user_username', :with => user.email
    fill_in 'user_password', :with => 'admin'
    click_on 'Login'
  end

  it 'show newsletters, preview, delete and edit', :js => true do
    visit all_newsletters_path

    within("#newsletter-#{newsletter.id}") do
      find(".info").should have_content(newsletter.subject)
      find(".send-test").should be_visible
      find(".send-live").should be_visible
      find(".stop").should_not be_visible

      find("a.preview").click
      sleep 1
    end

    page.should have_content(newsletter.content)
    find("a.close").click

    # delete
    within("#newsletter-#{newsletter.id}") do
      find("a.delete").click
      page.driver.browser.switch_to.alert.accept
      sleep 1
    end

    page.should have_no_selector("#newsletter-#{newsletter.id}")

    #edit
    within("#newsletter-#{newsletter2.id}") do
      find("td.info").should have_content(newsletter2.subject)
      find(".send-test").should be_visible
      find(".send-live").should_not be_visible

      find("a.edit").click
    end

    #redirected
    page.should have_content('Absender')
    page.should have_selector("textarea.cleditor")
  end

  it 'sends test newsletter', :js => true do
    visit account_newsletters_path(account)

    page.should have_no_selector("#newsletter-#{newsletter2.id}.tested")

    expect do
      find("#newsletter-#{newsletter2.id} a.send-test").click
      sleep 1
      page.should have_selector("#newsletter-#{newsletter2.id}.testing")

      ResqueSpec.perform_next(Newsletter::QUEUE)
      ResqueSpec.perform_all(SendOut::QUEUE)
    end.to change(ActionMailer::Base.deliveries, :size).by(3)
    sleep 5

    page.should have_selector("#newsletter-#{newsletter2.id}.tested")
  end

  it 'sends live newsletter', :js => true do
    visit account_newsletters_path(account)

    expect do
      find("#newsletter-#{newsletter.id} a.send-live").click
      page.driver.browser.switch_to.alert.accept
      sleep 1
      page.should have_selector("#newsletter-#{newsletter.id}.sending")
      #procesbar visible

      find("#newsletter-#{newsletter.id} .progress-bar").should be_visible
      ResqueSpec.perform_next(Newsletter::QUEUE)
      sleep 1
      #show ? %
      ResqueSpec.perform_next(SendOut::QUEUE)
      sleep 3
      page.should have_content('50%')
      ResqueSpec.perform_next(SendOut::QUEUE)
    end.to change(ActionMailer::Base.deliveries, :size).by(2)
    sleep 3
    page.should have_content('100%')
    page.should have_selector("#newsletter-#{newsletter.id}.finished")
  end


  it 'stops live newsletter', :js => true do
    visit account_newsletters_path(account)

    expect do
      find("#newsletter-#{newsletter.id} a.send-live").click
      page.driver.browser.switch_to.alert.accept
      sleep 1
      page.should have_selector("#newsletter-#{newsletter.id}.sending")
      #procesbar visible

      find("#newsletter-#{newsletter.id} .progress-bar").should be_visible
      ResqueSpec.perform_next(Newsletter::QUEUE)
      sleep 1
      #show ? %
      ResqueSpec.perform_next(SendOut::QUEUE)
      sleep 3
      page.should have_content('50%')

      find("#newsletter-#{newsletter.id} a.stop").click
      page.driver.browser.switch_to.alert.accept
      sleep 2
      page.should have_selector("#newsletter-#{newsletter.id}.stopping")
      ResqueSpec.perform_next(Newsletter::QUEUE)
    end.to change(ActionMailer::Base.deliveries, :size).by(1)
    sleep 3
    page.should have_selector("#newsletter-#{newsletter.id}.stopped")
    page.should have_content('50%')
  end
end


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

  context "sending" do
    before do
      visit account_newsletters_path(account)
    end

    it 'sends test newsletter', :js => true do
      selector = "#newsletter-#{newsletter2.id}"

      page.should have_no_selector("#{selector}.tested")

      expect do
        find("#{selector} a.send-test").click
        sleep 1
        page.should have_selector("#newsletter-#{newsletter2.id}.pre_testing")
        find("#{selector} .progress-bar").should be_visible

        ResqueSpec.perform_next(Newsletter::QUEUE)
        sleep 1
        page.should have_selector("#{selector}.testing")

        ResqueSpec.perform_all(SendOut::QUEUE)
      end.to change(ActionMailer::Base.deliveries, :size).by(3)
      sleep 5

      page.should have_selector("#{selector}.tested")
    end

    it 'sends live newsletter', :js => true do
      selector = "#newsletter-#{newsletter.id}"

      expect do
        find("#{selector} a.send-live").click
        page.driver.browser.switch_to.alert.accept
        sleep 1
        page.should have_selector("#{selector}.pre_sending")
        find("#{selector} .progress-bar").should be_visible

        ResqueSpec.perform_next(Newsletter::QUEUE)
        sleep 1
        page.should have_selector("#{selector}.sending")

        ResqueSpec.perform_next(SendOut::QUEUE)
        sleep 1
        page.should have_content('50%')
        ResqueSpec.perform_next(SendOut::QUEUE)
        sleep 1
        page.should have_content('100%')
      end.to change(ActionMailer::Base.deliveries, :size).by(2)

      page.should have_selector("#{selector}.finished")
    end

    it 'stops and resume live newsletter', :js => true do
      selector = "#newsletter-#{newsletter.id}"

      expect do
        find("#{selector} a.send-live").click
        page.driver.browser.switch_to.alert.accept
        sleep 1
        page.should have_selector("#{selector}.pre_sending")
        find("#{selector} .progress-bar").should be_visible

        ResqueSpec.perform_next(Newsletter::QUEUE)
        ResqueSpec.perform_next(SendOut::QUEUE)
        sleep 1
        page.should have_content('50%')
      end.to change(ActionMailer::Base.deliveries, :size).by(1)

      find("#{selector} a.stop").click
      page.driver.browser.switch_to.alert.accept
      sleep 1
      page.should have_selector("#{selector}.stopping")

      ResqueSpec.perform_next(Newsletter::QUEUE)
      ResqueSpec.perform_all(SendOut::QUEUE)
      sleep 1
      page.should have_content('50%')
      page.should have_selector("#{selector}.stopped")

     # sleep 100

      newsletter.live_send_outs.with_state(:stopped).count.should == 1

      expect do
        find("#{selector} a.resume").click
        page.driver.browser.switch_to.alert.accept
        sleep 1
        page.should have_selector("#{selector}.pre_sending")

        ResqueSpec.perform_next(Newsletter::QUEUE)
        sleep 1
        page.should have_selector("#{selector}.sending")
        ResqueSpec.perform_next(SendOut::QUEUE)
        sleep 1
        page.should have_content('100%')
        page.should have_selector("#{selector}.finished")
      end.to change(ActionMailer::Base.deliveries, :size).by(1)
    end
  end
end


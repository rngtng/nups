# encoding: UTF-8
require 'spec_helper'

describe 'devise' do
  fixtures :users

  let(:user) { users(:biff) }

  it 'shows login' do
    visit '/'
    page.should have_content('Benutzername')
    page.should have_content('Passwort')
  end

  it "logs in" do
    visit '/'
    fill_in 'user_username', :with => user.email
    fill_in 'user_password', :with => 'admin'
    click_on 'Login'
    page.should have_content('Übersicht Newsletter')
  end
end

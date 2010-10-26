class Admin::AdminController < ApplicationController

  before_filter :authenticate_admin!

  def authenticate_admin!
    render_403 unless current_user.admin?
  end 
end

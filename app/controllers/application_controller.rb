class ApplicationController < ActionController::Base
  protect_from_forgery
  layout :layout_by_resource

  before_filter :set_user_language

  def render_403
    render :file => "public/404", :layout => false, :status => 403
  end

  def render_404
    render :file => "public/404", :layout => false, :status => 404
  end

  protected
  def load_account
    klass = current_user.admin? ? Account : current_user.accounts
    @account = klass.find_by_id(params[:account_id]) || klass.find_by_permalink(params[:account_permalink])
    render_404 unless @account
  end

  private
  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end

  def set_user_language
    I18n.locale = 'de'
  end
end

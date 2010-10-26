class ApplicationController < ActionController::Base
  protect_from_forgery
  layout :layout_by_resource

#  before_filter :authenticate_user!, :unless => proc { |c| c.devise_controller? } #TODO remove this hack!!

  before_filter :set_user_language

  def render_403
    render :file => "public/404", :layout => false, :status => 403
  end

  def render_404
    render :file => "public/404", :layout => false, :status => 404
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

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_user_language

  def render_403
    respond_to do |format|
      format.html { render :file => "public/403", :layout => false, :status => :forbidden }
      format.json  { head :forbidden }
    end
  end

  def render_404
    respond_to do |format|
      format.html { render :file => "public/404", :layout => false, :status => :not_found }
      format.json  { head :not_found }
    end
  end

  protected
  def load_account
    klass = current_user.admin? ? Account : current_user.accounts
    @account = klass.find_by_id(params[:account_id])
    render_404 unless @account
  end

  private

  def set_user_language
    I18n.locale = 'de'
  end
end

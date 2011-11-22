class RecipientsController < ApplicationNupsController
  before_filter :load_account

  respond_to :html, :xls

  def index
    @recipients = @account.recipients.search(params[:search])

    unless params[:format] == 'xls'
      @recipients = @recipients.with_states(:confirmed).order(params[:order] || :id).page(params[:page]).per(10)
    end
    if request.xhr?
      render :partial => 'recipients'
    else
      respond_with @recipients
    end
  end

  def show
    @recipient = @account.recipients.find(params[:id])
  end

  def new
    render :layout => !request.xhr?
  end

  def create
    @valid_recipients   ||= []
    @invalid_recipients ||= []

    split_emails(params[:emails]).each do |email|
      recipient = @account.recipients.new(:email => email)
      if recipient.save && recipient.confirm!
        @valid_recipients << recipient
      else
        @invalid_recipients << recipient
      end
    end

    if request.xhr?
      render :json => {:valid => @valid_recipients.map(&:email), :invalid => @invalid_recipients.map(&:email)}
    else
      render :new, :layout => !request.xhr?
    end
  end

  def update
    @recipient = @account.recipients.find(params[:id])
    @recipient.update_attributes(params[:recipient])

    if request.xhr?
      render :partial => "recipient"
    else
      redirect_to account_recipients_url(@account)
    end
  end

  def delete
    render :layout => !request.xhr?
  end

  def multiple_destroy
    @valid_recipients  = []
    @invalid_recipients  = []

    split_emails(params[:emails]).each do |email|
      if recipient = @account.recipients.where(:email => email).first
        recipient.destroy unless params[:delete].blank?
        @valid_recipients << recipient
      else
        @invalid_recipients << @account.recipients.new(:email => email)
      end
    end

    if request.xhr?
      render :json => {:valid => @valid_recipients.map(&:email), :invalid => @invalid_recipients.map(&:email), :delete => params[:delete]}
    else
      redirect_to account_recipients_url(@account)
    end
  end

  def destroy
    @recipient = @account.recipients.find(params[:id])
    @recipient.destroy

    if request.xhr? #TODO render recipient with new state
      render :js => "$('#recipient_#{@recipient.id}').hide()"
    else
      redirect_to account_recipients_url(@account)
    end
  end

  private
  def load_account
    klass = current_user.admin? ? Account : current_user.accounts
    @account = klass.find_by_id(params[:account_id])
    render_404 unless @account
  end

  def split_emails(emails)  #split by \n or , or ;
    return [] unless emails
    emails.delete("\"' ").split(/[\n,;]/).delete_if(&:blank?).map(&:strip).uniq
  end
end

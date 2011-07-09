class RecipientsController < ApplicationNupsController
  before_filter :load_account

  respond_to :html, :xls

  def index
    @recipients = @account.recipients.search(params[:search])

    unless params[:format] == 'xls'
      @recipients = @recipients.page(params[:page]).per(100)
    end

    respond_with @recipients
  end

  def show
    @recipient = @account.recipients.find(params[:id])
  end

  def new
    @valid_recipients   ||= []
    @invalid_recipients ||= []
  end

  def create
    @valid_recipients   ||= []
    @invalid_recipients ||= []

    if params[:emails]
      split_emails(params[:emails]).each do |email|
        recipient = @account.recipients.new(:email => email)
        if recipient.save
          @valid_recipients << recipient
        else
          @invalid_recipients << recipient
        end
      end
    end
    render :new
  end

  def update
    @recipient = @account.recipients.find(params[:id])
    @recipient.update_attributes(params[:recipient])

    if request.xhr?
      render :partial => "recipient"
    else
      redirect_to( account_recipients_url(@account) )
    end
  end

  def multiple_delete
    @valid_recipients  = []
    @invalid_recipients  = []

    return if params[:emails].blank?

    split_emails(params[:emails]).each do |email|
      recipient = @account.recipients.where(:email => email).first || @account.recipients.new(:email => email)
      recipient.delete unless params[:delete].blank? #TODO what happens with log etc !?

      unless recipient.new_record?
        @valid_recipients << recipient
      else
        @invalid_recipients << recipient
      end
    end
  end

  def destroy
    @recipient = @account.recipients.find(params[:id])
    @recipient.destroy

    if request.xhr?
      render :js => "$('#recipient_#{@recipient.id}').hide()"
    else
      redirect_to( account_recipients_url(@account) )
    end
  end

  private
  def load_account
    klass = current_user.admin? ? Account : current_user.accounts
    @account = klass.find_by_id(params[:account_id])
    render_404 unless @account
  end

  def split_emails(emails)  #split by \n or , or ;
    emails.delete("\"' ").split(/[\n,;]/).delete_if(&:blank?).map(&:strip)
  end
end

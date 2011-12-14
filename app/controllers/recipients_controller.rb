class RecipientsController < ApplicationNupsController
  before_filter :load_account

  respond_to :html, :xls

  def index
    @recipients = @account.recipients.search(params[:search])

    unless params[:format] == 'xls'
      @recipients = @recipients.with_states(:confirmed).order(params[:order] || :id).page(params[:page]).per(50)
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
    @valid_recipients = []
    @invalid_recipients = split_emails(params[:emails]).map do |email|
      recipient = @account.recipients.find_or_build_by(:email => email)
      if recipient.save && recipient.confirm!
        @valid_recipients << recipient
        nil
      else
        recipient
      end
    end.compact

    if request.xhr?
      render :json => {:valid => @valid_recipients.map(&:email), :invalid => @invalid_recipients.map(&:email)}
    else
      render :new, :layout => false
    end
  end

  def update
    @recipient = @account.recipients.find(params[:id])
    @recipient.update_attributes(params[:recipient])

    if request.xhr?
      render :json => @recipient
    else
      redirect_to account_recipients_url(@account)
    end
  end

  def delete
    render :layout => !request.xhr?
  end

  def multiple_destroy
    valids  = []
    invalids = split_emails(params[:emails]).delete_if do |email|
      if recipient = @account.recipients.find_by_email(email)
        recipient.destroy unless params[:delete].blank?
        valids << email
        true
      end
    end

    if request.xhr?
      render :json => {:valid => valids, :invalid => invalids, :delete => params[:delete]}
    else
      redirect_to account_recipients_path(@account)
    end
  end

  def destroy
    @recipient = @account.recipients.find(params[:id])
    @recipient.destroy

    if request.xhr?
      render :json => @recipient
    else
      redirect_to account_recipients_path(@account)
    end
  end

  private
  def split_emails(emails)  #split by \n or , or ;
    return [] unless emails
    emails.delete("\"' ").split(/[\n,;]/).delete_if(&:blank?).map(&:strip).uniq
  end
end

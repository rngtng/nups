class Public::RecipientsController < ApplicationController
  layout 'public'

  before_filter :load_account, :only => [:create, :destroy_by_email]
  before_filter :load_recipient, :only => [:confirm, :destroy_confirm, :destroy]

  respond_to :html, :json

  def create
    @recipient = @account.recipients.new(params[:recipient])

    respond_to do |format|
      if @recipient.save
        @recipient.confirm! if params[:auto_confirm]
        format.html
        format.json { render :json => { :confirm_path => confirm_path(@recipient.confirm_code) }, :status => :created }
      else
        format.html
        format.json { render :json => @recipient.errors, :status => :unprocessable_entity }
      end
    end
  end

  def confirm
    respond_to do |format|
      if @recipient.confirm
        format.html
        format.json { render :json => { :email => @recipient.email }, :status => :ok }
      else
        format.html
        format.json { render :json => @recipient.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy_confirm
  end

  def destroy_by_email
    if @recipient = @account.recipients.without_state('deleted').find_by_email(params[:email])
      destroy
    else
      render_404
    end
  end

  def destroy
    @recipient.destroy

    respond_to do |format|
      format.html { render :action => 'destroy' }
      format.json { head :ok }
    end
  end

  protected
  def load_account
    @account = Account.find_by_permalink(params[:account_permalink])
    render_404 unless @account
  end

  def load_recipient
    @recipient = Recipient.without_state('deleted').find_by_confirm_code(params[:recipient_confirm_code])
    render_404 unless @recipient
  end
end

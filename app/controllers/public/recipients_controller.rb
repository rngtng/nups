class Public::RecipientsController < ApplicationController
  layout 'public'

  before_filter :load_account, :except => [:index]

  respond_to :html, :json

  def index
  end

  def show
    @recipient = @account.recipients.find(params[:id])
  end

  def new
    @recipient = @account.recipients.new

    respond_to do |format|
      format.html # new.html.erb
      format.json  { render :json => @recipient }
    end
  end

  def edit
    @recipient = @account.recipients.find(params[:id])
  end

  def create
    @recipient = @account.recipients.new(params[:recipient])

    respond_to do |format|
      if @recipient.save
        format.html { redirect_to( account_recipients_path(@account), :notice => '@account.recipients was successfully created.') }
        format.json  { render :json => @recipient, :status => :created, :location => @recipient }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @recipient.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @recipient = @account.recipients.find(params[:id])

    respond_to do |format|
      if @recipient.update_attributes(params[:recipient])
        format.html { redirect_to( account_recipients_path(@account), :notice => '@account.recipients was successfully updated.') }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @recipient.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @recipient = @account.recipients.find(params[:id])
    @recipient.destroy

    respond_to do |format|
      format.html { redirect_to( public_recipients_url ) }
      format.json  { head :ok }
    end
  end

end

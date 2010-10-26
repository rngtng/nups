class Public::RecipientsController < ApplicationController
  layout 'public'
  
  before_filter :load_account, :except => [:index]

  respond_to :html, :xls
  
  def index
  end

  def show
    @recipient = @account.recipients.find(params[:id])
  end

  def new
    @recipient = @account.recipients.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @recipient }
    end
  end

  # GET /recipients/1/edit
  def edit
    @recipient = @account.recipients.find(params[:id])
  end

  # POST /recipients
  # POST /recipients.xml
  def create
    @recipient = @account.recipients.new(params[:recipient])

    respond_to do |format|
      if @recipient.save
        format.html { redirect_to( account_recipients_path(@account), :notice => '@account.recipients was successfully created.') }
        format.xml  { render :xml => @recipient, :status => :created, :location => @recipient }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @recipient.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /recipients/1
  # PUT /recipients/1.xml
  def update
    @recipient = @account.recipients.find(params[:id])

    respond_to do |format|
      if @recipient.update_attributes(params[:recipient])
        format.html { redirect_to( account_recipients_path(@account), :notice => '@account.recipients was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @recipient.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /recipients/1
  # DELETE /recipients/1.xml
  def destroy
    @recipient = @account.recipients.find(params[:id])
    @recipient.destroy

    respond_to do |format|
      format.html { redirect_to( public_recipients_url ) }
      format.xml  { head :ok }
    end
  end
  
  private
  def load_account
    @account = Account.find_by_id(params[:account_id])
    render_404 unless @account
  end

end

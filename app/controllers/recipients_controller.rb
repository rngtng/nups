class RecipientsController < ApplicationNupsController
  before_filter :load_account

  respond_to :html, :xls

  def index
    @recipients = @account.recipients.search(params[:search])

    unless params[:format] == 'xls'
      @recipients = @recipients.paginate(:page => params[:page], :per_page => 100)
    end

    respond_with @recipients
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

  def import
    @valid_recipients  = []
    @invalid_recipients  = []

    return if params[:emails].blank?

    split_emails(params[:emails]).each do |email|
      recipient = @account.recipients.new(:email => email)
      if recipient.save
        @valid_recipients << recipient
      else
        @invalid_recipients << recipient
      end
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
      format.html { redirect_to( account_recipients_url(@account) ) }
      format.xml  { head :ok }
    end
  end

  private
  def load_account
    klass = current_user.admin? ? Account : current_user.accounts
    @account = klass.find_by_id(params[:account_id])
    render_404 unless @account
  end

  def split_emails( emails )  #split by \n or , or ;
    emails.delete("\"' ").split(/[\n,;]/).delete_if(&:blank?).map(&:strip)
  end
end

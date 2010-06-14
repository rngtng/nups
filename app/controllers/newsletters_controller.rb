class NewslettersController < ApplicationController
  before_filter :load_user, :load_account

  def index
    @accounts    = current_user.admin? ? Account.all : current_user.accounts
    @newsletters = @user.newsletters.with_account(@account).all( :order => 'id DESC', :limit => 20 )
  end  

  # GET /newsletters/1
  # GET /newsletters/1.xml
  def show
    @newsletter = @user.newsletters.with_account(@account).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @newsletter }
    end
  end

  # GET /newsletters/new
  # GET /newsletters/new.xml
  def new
    redner404 && return unless @account
    @newsletter = @account.newsletters.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @newsletter }
    end
  end

  # GET /newsletters/1/edit
  def edit
    @newsletter = @account.newsletters.find(params[:id])
  end

  # POST /newsletters
  # POST /newsletters.xml
  def create
    @newsletter = @account.newsletters.new(params[:newsletter])

    respond_to do |format|
      if @newsletter.save
        format.html { redirect_to([@account, @newsletter], :notice => 'Newsletter was successfully created.') }
        format.xml  { render :xml => @newsletter, :status => :created, :location => @newsletter }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @newsletter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /newsletters/1
  # PUT /newsletters/1.xml
  def update
    @newsletter = @account.newsletters.find(params[:id])

    respond_to do |format|
      if @newsletter.update_attributes(params[:newsletter])
        format.html { redirect_to([@account, @newsletter], :notice => 'Newsletter was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @newsletter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /newsletters/1
  # DELETE /newsletters/1.xml
  def destroy
    @newsletter = @account.newsletters.find(params[:id])
    @newsletter.destroy

    respond_to do |format|
      format.html { redirect_to(newsletters_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  def load_user
    @user = current_user
    @user = User.find(params[:user_id]) if params[:user_id] && current_user.admin?
  end

  def load_account
    return if params[:account_id].blank?
    klass = current_user.admin? ? Account : current_user.accounts
    @account = klass.find(params[:account_id])
  end  
end

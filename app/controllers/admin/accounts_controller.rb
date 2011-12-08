class Admin::AccountsController < Admin::AdminController

  before_filter :load_account, :except => [:index, :new, :create]

  def index
    @accounts = Account.all
  end

  def show
  end

  def new
    @account = Account.new
  end

  def edit
  end

  def create
    @account = Account.new(params[:account])

    respond_to do |format|
      if @account.save
        format.html { redirect_to(admin_accounts_path, :notice => 'Account was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @account.update_attributes(params[:account])
        format.html { redirect_to(admin_accounts_path, :notice => 'Account was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @account.destroy

    redirect_to(admin_accounts_path)
  end

  protected
  def load_account
    klass = current_user.admin? ? Account : current_user.accounts
    @account = klass.find_by_id(params[:id])
    render_404 unless @account
  end
end

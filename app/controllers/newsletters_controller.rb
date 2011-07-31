class NewslettersController < ApplicationNupsController
  before_filter :load_account

  respond_to :html

  LIMIT = 20

  def index
    @user        = User.find(params[:user_id]) if params[:user_id] && current_user.admin?
    @user      ||= (@account) ? @account.user : current_user
    @newsletters = @user.newsletters.with_account(@account)
    @accounts    = current_user.admin? ? Account.all : @user.accounts

    @newsletters = @newsletters.scoped(:order => 'updated_at DESC').page(params[:page]).per(100)

    if request.xhr?
      #TODO only update those who need update
      @newsletters.all.map(&:update_stats)
      render @newsletters #without_states(:new, :tested, :stopped, :finished).all
    end
  end

  def show
    @newsletter = @account.newsletters.find(params[:id])

    if request.xhr?
      recipient = Recipient.new(:email => current_user.email)
      @newsletter_issue = NewsletterMailer.issue(@newsletter, recipient)
      render :text => @newsletter_issue.html_part.body.decoded, :layout => false
    else
      render :show
    end
  end

  def new
    redner404 && return unless @account

    draft = @account.newsletters.find_by_id(params[:draft_id])
    @newsletter = @account.newsletters.new(:draft => draft)
    @newsletter.subject ||= @account.subject

    respond_with @newsletter
  end

  def edit
    @newsletter = @account.newsletters.find(params[:id])
    render :new
  end

  def create
    # fix to make attachment_id not break
    params[:newsletter] = {:account => @account}.merge(params[:newsletter]) if params[:newsletter]

    @newsletter = @account.newsletters.new(params[:newsletter])

    if @newsletter.save
      redirect_to( account_newsletters_path(@account), :notice => 'Newsletter was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @newsletter = @account.newsletters.find(params[:id])

    if @newsletter.update_attributes(params[:newsletter])
      redirect_to( account_newsletters_path(@account), :notice => 'Newsletter was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @newsletter = @account.newsletters.find(params[:id])
    @newsletter.destroy

    redirect_to account_newsletters_path(@account)
  end

  ########################################################

  def start
    @newsletter = @account.newsletters.find(params[:id])

    if params[:mode] == 'live'
      @newsletter.send_live!
    else
      @newsletter.send_test!
    end

    if request.xhr?
      render @newsletter
    else
      redirect_to account_newsletters_path(@account)
    end
  end

  def stop
    @newsletter = @account.newsletters.find(params[:id])
    @newsletter.stop!

    if request.xhr?
      render @newsletter
    else
      redirect_to account_newsletters_path(@account)
    end
  end

  ########################################################

  private
  def load_account
    return if params[:account_id].blank?
    klass = current_user.admin? ? Account : current_user.accounts
    @account = klass.find_by_id(params[:account_id])
    render_403 unless @account
  end

end

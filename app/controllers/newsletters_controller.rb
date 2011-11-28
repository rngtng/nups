class NewslettersController < ApplicationNupsController
  before_filter :load_account, :if => lambda { params[:account_id] }

  respond_to :html

  def index
    @user        = User.find(params[:user_id]) if params[:user_id] && current_user.admin?
    @user      ||= (@account) ? @account.user : current_user
    @accounts    = current_user.admin? ? Account.all : @user.accounts

    @newsletters = @user.newsletters.with_account(@account).scoped(:order => 'created_at DESC').page(params[:page]).per(15)
    if request.xhr?
      render :partial => 'newsletters'
    end
  end

  def stats
    @newsletters = current_user.admin? ? Newsletter : current_user.newsletters
    @newsletters = @newsletters.find_all_by_id(params[:ids])
    @newsletters.map(&:update_stats!)
  end

  def show
    @newsletter = @account.newsletters.find(params[:id])

    recipient = Recipient.new(:email => current_user.email)
    @newsletter_issue = NewsletterMailer.issue(@newsletter, recipient)
    render :text => @newsletter_issue.html_part.body.decoded, :layout => false
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

    if request.xhr?
      render :js => "$('#newsletter-#{@newsletter.id}').hide()"
    else
      redirect_to account_newsletters_path(@account)
    end
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

end

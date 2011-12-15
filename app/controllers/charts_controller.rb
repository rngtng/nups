class ChartsController < ApplicationNupsController
  before_filter :load_account

  respond_to :html

  def index
    @newsletters = @account.newsletters.with_state(:finished)

    @recipients = @account.recipients.select("state, created_at, updated_at").all
  end
end

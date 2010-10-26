class ApplicationNupsController < ApplicationController
  layout 'application'
  
  before_filter :authenticate_user! #, :unless => proc { |c| c.devise_controller? } #TODO remove this hack!!

end

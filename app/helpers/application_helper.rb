module ApplicationHelper
  
  def resque_status
    Resque.redis #check if we can connect to redis server
    Resque.workers.any? ? :ok : :no_worker
    rescue
      :no_server
  end
end

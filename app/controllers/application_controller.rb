class ApplicationController < ActionController::Base

  protect_from_forgery

  def configurator(key)
    Clearing::Application.config.application[key]
  end

end

class ApplicationController < ActionController::Base

  protect_from_forgery

  def configurator(key)
    Clearing::Application.config.application[key]
  end
  
  def object_errors(object)
    ' ' + object.errors.full_messages.join('. ') + '.'
  end

end

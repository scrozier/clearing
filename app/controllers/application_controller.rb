class ApplicationController < ActionController::Base

  protect_from_forgery

  def configurator(key)
    Clearing::Application.config.application[key]
  end
  
  def object_errors(object)
    ' ' + object.errors.full_messages.join('. ') + '.'
  end

  def contact_us
    "Contact us #{view_context.mail_to 'info@concertsintheclearing.org', 'by email'} or call First Unitarian Church at 214.528.3990."
  end
  
end

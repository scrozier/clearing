Clearing::Application.config.application = {
  :ticket_limit_per_person => 8,
  :contact_email           => 'info@concertsintheclearing.org'
  }

class BigDecimal
  
  def to_dollar_amount
    sprintf('$%0.2f', self)
  end

end
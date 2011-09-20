class Notifier < ActionMailer::Base
  
  helper :application
  
  default :from => 'info@concertsintheclearing.org',
          :return_path => 'info@concertsintheclearing.org'
  
  def tickets(reservation, unique_token)
    @reservation = reservation
    @unique_token = unique_token
    mail(:to => reservation.patron.email)
  end

end

class Notifier < ActionMailer::Base
  
  default :from => 'info@concertsintheclearing.org',
          :return_path => 'info@concertsintheclearing.org'
  
  def tickets(reservation)
    @reservation = reservation
    mail(:to => reservation.patron.email)
  end

end

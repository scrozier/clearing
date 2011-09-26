class Notifier < ActionMailer::Base
  
  helper :application
  
  default :from => 'info@concertsintheclearing.org',
          :return_path => 'info@concertsintheclearing.org'
  
  def tickets(reservation)
    @reservation = reservation
    @unique_token = reservation.unique_token
    mail(:to => reservation.patron.email)
  end

  def donation(donation)
    @donation = donation
    mail(:to => @donation.patron.email)
  end

end

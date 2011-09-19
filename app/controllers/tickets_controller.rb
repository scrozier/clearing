class TicketsController < ApplicationController
  
  def show
    @concert = Concert.where(:ident_string => params[:ident_string]).first
  end
  
  def reserve
    
    concert = Concert.find(params[:concert_id])
    raise 'could not find concert' unless concert

    patron = Patron.where(:email => params[:email]).first
    unless patron
      patron = Patron.create(
        :first_name => params[:first_name],
        :last_name => params[:last_name],
        :email => params[:email]
        )
      unless patron.valid?
        flash[:error] = "There was a problem with what you entered." + object_errors(patron)
        redirect_to concert_url(:ident_string => concert.ident_string)
      end
    end
    
    unless params[:number_of_tickets]
      flash[:error] = 'Please select the number of tickets you want to reserve.'
      redirect_to concert_url(:ident_string => concert.ident_string)
    end
    number_of_tickets = params[:number_of_tickets].to_i
    
    # have the (new or existing) patron record, create the reservation
    @reservation = patron.reservations.create(
      :concert_id => concert.id,
      :number_of_tickets => params[:number_of_tickets]
      )
    unless @reservation
      flash[:error] = 'There was a problem reserving your tickets. ' + contact_us
    end
    Notifier.tickets(@reservation).deliver
    render :action => :ticket_success
    
  end
  
  def ticket_success
  end
  
end
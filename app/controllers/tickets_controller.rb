class TicketsController < ApplicationController
  
  include Chargeable
  
  def show
    @concert = Concert.where(:ident_string => params[:ident_string]).first
    @in_memory_of = @in_memory_by = ''
  end
  
  def donation_confirm
  end
  
  def ticket_success
  end
  
  def print

    @reservation = Reservation.where(:unique_token => params[:unique_token]).first
    unless @reservation
      flash[:error] = 'Could not locate your ticket. ' + contact_us
      redirect_to root_path
    end
    render :layout => 'printed_ticket'
  end
  
  def process_reservation(number_of_tickets, in_memory_of, in_memory_by)

    unique_token = Digest::SHA1.hexdigest Time.now.to_s
    @patron.reservations.create(
      :concert_id => @concert.id,
      :number_of_tickets => number_of_tickets,
      :unique_token => unique_token,
      :in_memory_of => in_memory_of,
      :in_memory_by => in_memory_by
      )

  end
  
end
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
        redirect_to show_ticket_form_url(:ident_string => concert.ident_string) and return
      end
    end
    
    unless params[:number_of_tickets]
      flash[:error] = 'Please select the number of tickets you want to reserve.'
      redirect_to show_ticket_form_url(:ident_string => concert.ident_string) and return
    end
    number_of_tickets = params[:number_of_tickets].to_i
    
    # process donation, if made
    
    donation = nil
    if params[:donation] == 'true'
      donation = Donation.new(
        :patron_id => patron.id,
        :concert_id => concert.id,
        :credit_card_ends_with => params[:credit_card_number][-4, 4],
        :amount => params[:amount]
        )
      donation.credit_card_type = params[:credit_card_type]
      donation.credit_card_number = params[:credit_card_number]
      donation.credit_card_expiration_month = params[:credit_card_expires_month]
      donation.credit_card_expiration_year = params[:credit_card_expires_year]
      donation.credit_card_verification = params[:credit_card_verification]
      donation.credit_card_first_name = params[:credit_card_first_name]
      donation.credit_card_last_name = params[:credit_card_last_name]
      donation.amount = BigDecimal.new(params[:amount])
      
      unless donation.card_valid?
        flash[:error] = 'Invalid credit card information. Please re-enter.'
        redirect_to show_ticket_form_url(:ident_string => concert.ident_string) and return
      end
      
      success, message = donation.process_payment
      
      unless success
        flash[:error] = 'Credit card transaction could not be processed: ' + message + '. Your ticket reservation was not processed. Please re-submit, omitting or changing your donation as necessary.'
        redirect_to show_ticket_form_url(:ident_string => concert.ident_string) and return
      end

      donation.save!
      donation.update_attribute(:transaction_code, message) or raise 'could not update transaction code'
    end
    
    # create the reservation
    unique_token = Digest::SHA1.hexdigest Time.now.to_s
    @reservation = patron.reservations.create(
      :concert_id => concert.id,
      :number_of_tickets => params[:number_of_tickets],
      :unique_token => unique_token
      )
    unless @reservation
      if donation
        flash[:error] = 'Your donation was processed, but there was an error reserving your tickets. Please re-try your ticket reservation&mdash;do not submit another donation&mdash;or ' + contact_us
      else
        flash[:error] = 'There was a problem reserving your tickets. ' + contact_us
      end
      redirect_to show_ticket_form_url(:ident_string => concert.ident_string) and return
    end
    
    Notifier.tickets(@reservation, unique_token, donation).deliver
    render :action => :ticket_success and return
    
  end
  
  def ticket_success
  end
  
  def print
    @reservation = Reservation.where(:unique_token => params[:unique_token]).first
    raise 'could not find reservation' unless @reservation
  end
  
end
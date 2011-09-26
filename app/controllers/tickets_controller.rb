class TicketsController < ApplicationController
  
  def show
    @concert = Concert.where(:ident_string => params[:ident_string]).first
  end
  
  def reserve
    
    @params = params
    
    @concert = Concert.find(params[:concert_id])
    raise 'could not find concert' unless @concert

    @patron = Patron.where(:email => params[:email]).first
    unless @patron
      @patron = Patron.create(
        :first_name => params[:first_name],
        :last_name => params[:last_name],
        :email => params[:email]
        )
    end

    @donation = nil
    if params[:donation] == 'true'
      @donation = Donation.new(
        :patron_id => @patron.id,
        :concert_id => @concert.id,
        :credit_card_ends_with => params[:credit_card_number][-4, 4],
        :amount => params[:amount]
        )
      @donation.credit_card_type = params[:credit_card_type]
      @donation.credit_card_number = params[:credit_card_number]
      @donation.credit_card_expiration_month = params[:credit_card_expiration_month]
      @donation.credit_card_expiration_year = params[:credit_card_expiration_year]
      @donation.credit_card_verification = params[:credit_card_verification]
      @donation.credit_card_first_name = params[:credit_card_first_name]
      @donation.credit_card_last_name = params[:credit_card_last_name]
      @donation.amount = BigDecimal.new(params[:amount])
    end
    
    @number_of_tickets = params[:number_of_tickets].to_i
      
    unless @patron.valid?
      flash.now[:error] = "There was a problem with what you entered." + object_errors(@patron)
      render :action => :show
      return
    end
    
    unless params[:number_of_tickets]
      flash.now[:error] = 'Please select the number of tickets you want to reserve.'
      render :action => :show
      return
    end
    number_of_tickets = params[:number_of_tickets].to_i
    
    unless @donation.amount > 0.0
      flash.now[:error] = 'Please enter a donation amount.'
      render :action => :show
      return
    end

    # process donation, if made
    
    if params[:donation] == 'true'
      unless @donation.card_valid?
        flash.now[:error] = 'Invalid credit card information.'
        render :action => :show
        return
      end
    end
    
    if params[:donation] == 'true'
      
      success, message = @donation.process_payment
      
      unless success
        flash.now[:error] = 'Credit card transaction could not be processed: ' + message + '. Your ticket reservation was not processed. Please re-submit, omitting or changing your donation as necessary.'
        render :action => :show
        return
      end

      @donation.save!
      @donation.update_attribute(:transaction_code, message) or raise 'could not update transaction code'
    end
    
    # create the reservation
    unique_token = Digest::SHA1.hexdigest Time.now.to_s
    @reservation = @patron.reservations.create(
      :concert_id => @concert.id,
      :number_of_tickets => params[:number_of_tickets],
      :unique_token => unique_token
      )
    unless @reservation
      if @donation
        flash.now[:error] = 'Your donation was processed, but there was an error reserving your tickets. Please re-try your ticket reservation&mdash;do not submit another donation&mdash;or ' + contact_us
      else
        flash.now[:error] = 'There was a problem reserving your tickets. ' + contact_us
      end
      render :action => :show
      return
    end
    
    Notifier.tickets(@reservation, unique_token, @donation).deliver
    render :action => :ticket_success and return
    
  end
  
  def reserve_confirm
  end
  
  def ticket_success
  end
  
  def print
    @reservation = Reservation.where(:unique_token => params[:unique_token]).first
    unless @reservation
      flash[:error] = 'Could not locate your ticket. ' + contact_us
      redirect_to root_path
    end

  end
  
end
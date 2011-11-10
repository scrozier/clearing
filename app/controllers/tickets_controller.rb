class TicketsController < ApplicationController
  
  def show
    @concert = Concert.where(:ident_string => params[:ident_string]).first
    @in_memory_of = @in_memory_by = ''
  end
  
  def reserve
    
    # first do all the error checking...
    
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

    @make_donation = params[:make_donation]

    @donation = nil
    if @make_donation == 'true'
      @donation = Donation.new(
        :patron_id => @patron.id,
        :concert_id => @concert.id,
        :credit_card_ends_with => params[:credit_card_number][-4, 4],
        :amount => extract_donation_amount(params[:standard_amount], params[:amount])
        )
      fill_credit_card_info_from_params
    end
    
    @number_of_tickets = params[:number_of_tickets].to_i
    @in_memory_of = params[:in_memory_of]
    @in_memory_by = params[:in_memory_by]
      
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
    
    if @make_donation == 'true'

      unless @donation.card_valid?
        flash.now[:error] = 'Invalid credit card information.'
        render :action => :show
        return
      end
    
      if @donation.amount.nil? || @donation.amount <= BigDecimal.new('0')
        flash.now[:error] = 'Please enter a donation amount.'
        render :action => :show
        return
      end
      
    end
    
    if (@in_memory_of.present? && @in_memory_by.blank?) ||
      (@in_memory_of.blank? && @in_memory_by.present?)
      flash.now[:error] = 'For memorials, please enter both your name(s) and the name(s) of the person or persons to be memorialized.'
      render :action => :show
      return
    end
    
    # now actually process the reservation...
    
    @reservation = process_reservation(@number_of_tickets, params[:in_memory_of], params[:in_memory_by])
    unless @reservation
      flash.now[:error] = 'There was a problem reserving your tickets. ' + contact_us
      render :action => :show
      return
    end

    Notifier.tickets(@reservation).deliver

    if @make_donation == 'true'
      render :action => :donation_confirm and return
    else
      render :action => :ticket_success and return
    end
    
  end
  
  def donation_confirm
  end
  
  def process_donation

    @donation = Donation.new(
      :patron_id => params[:patron_id],
      :concert_id => params[:concert_id],
      :reservation_id => params[:reservation_id],
      :credit_card_ends_with => params[:credit_card_number][-4, 4],
      :amount => params[:amount]
      )
    fill_credit_card_info_from_params

    unless @donation.card_valid?
        flash.now[:error] = 'Credit card transaction could not be processed: ' + message + contact_us
        redirect_to root_path
        return
      end
      
    success, message = @donation.process_payment
    
    unless success
      flash.now[:error] = 'Credit card transaction could not be processed: ' + message + contact_us
      redirect_to root_path
      return
    end

    @donation.save!
    @donation.update_attribute(:transaction_code, message) or raise 'could not update transaction code'
    
    Notifier.donation(@donation).deliver
    
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
  
  def fill_credit_card_info_from_params
    @donation.credit_card_type = params[:credit_card_type]
    @donation.credit_card_number = params[:credit_card_number]
    @donation.credit_card_expiration_month = params[:credit_card_expiration_month]
    @donation.credit_card_expiration_year = params[:credit_card_expiration_year]
    @donation.credit_card_verification = params[:credit_card_verification]
    @donation.credit_card_first_name = params[:credit_card_first_name]
    @donation.credit_card_last_name = params[:credit_card_last_name]
  end
  
  def extract_donation_amount(standard_amount, amount)
    return amount if standard_amount.nil?
    return amount if standard_amount == 'other amount'
    return standard_amount.to_i
  end
  
end
module Chargeable

  def reserve_and_donate
    
    # does this include a reservation? some will, some will be just donations
    
    @includes_reservation = params[:concert_id].present?
    
    # first do all the error checking...
    
    if @includes_reservation
      @concert = Concert.find(params[:concert_id])
      raise 'could not find concert' unless @concert
    else
      @concert = nil
    end
    
    @patron = Patron.where(:email => params[:email]).first
    unless @patron
      @patron = Patron.create(
        :first_name => params[:first_name],
        :last_name => params[:last_name],
        :email => params[:email],
        :email_confirmation => params[:email_confirmation]
        )
    end

    @make_donation = (!@includes_reservation) || params[:make_donation] == 'true'

    @donation = nil
    if @make_donation
      @donation = Donation.new(
        :patron_id => @patron.id,
        :concert_id => (@concert ? @concert.id : nil),
        :credit_card_ends_with => params[:credit_card_number][-4, 4],
        :amount => extract_donation_amount(params[:standard_amount], params[:amount])
        )
      fill_credit_card_info_from_params
    end
    
    unless @patron.valid?
      flash.now[:error] = "There was a problem with what you entered." + object_errors(@patron)
      render :action => :show
      return
    end
  
    if @includes_reservation
      @number_of_tickets = params[:number_of_tickets].to_i
      @in_memory_of = params[:in_memory_of]
      @in_memory_by = params[:in_memory_by]

      unless params[:number_of_tickets].present?
        flash.now[:error] = 'Please select the number of tickets you want to reserve.'
        render :action => :show
        return
      end
    
    end
      
    if @make_donation

      unless @donation.card_valid?
        flash.now[:error] = 'Invalid credit card information.' + object_errors(@donation)
        render :action => :show
        return
      end
    
      unless address_ok
        flash.now[:error] = 'Please enter your complete billing address.'
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
    
    if @includes_reservation
      @reservation = process_reservation(@number_of_tickets, params[:in_memory_of], params[:in_memory_by])
      unless @reservation
        flash.now[:error] = 'There was a problem reserving your tickets. ' + contact_us
        render :action => :show
        return
      end

      Notifier.tickets(@reservation).deliver
    end

    if @make_donation
      render :action => :donation_confirm and return
    else
      render :action => :ticket_success and return
    end
    
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
      if @concert
        redirect_to show_ticket_form_path(@concert.ident_string) and return
      else
        redirect_to donate_path and return
      end
    end

    @donation.save!
    @donation.update_attribute(:transaction_code, message) or raise 'could not update transaction code'
    
    Notifier.donation(@donation).deliver
    
  end
  
  def fill_credit_card_info_from_params
    @donation.credit_card_type = params[:credit_card_type]
    @donation.credit_card_number = params[:credit_card_number]
    @donation.credit_card_expiration_month = params[:credit_card_expiration_month]
    @donation.credit_card_expiration_year = params[:credit_card_expiration_year]
    @donation.credit_card_verification = params[:credit_card_verification]
    @donation.credit_card_first_name = params[:credit_card_first_name]
    @donation.credit_card_last_name = params[:credit_card_last_name]
    @donation.credit_card_address = params[:credit_card_address]
    @donation.credit_card_city = params[:credit_card_city]
    @donation.credit_card_state = params[:credit_card_state]
    @donation.credit_card_zip = params[:credit_card_zip]
  end
  
  def extract_donation_amount(standard_amount, amount)
    return amount if standard_amount.nil?
    return amount if standard_amount == 'other amount'
    return standard_amount.to_i
  end
  
  def address_ok
    params[:credit_card_address].present? &&
    params[:credit_card_city].present? &&
    params[:credit_card_state].present? &&
    params[:credit_card_zip].present?
  end
  
end
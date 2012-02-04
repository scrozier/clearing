class Donation < ActiveRecord::Base

  belongs_to :patron
  validates_presence_of :patron_id
  
  belongs_to :concert
  belongs_to :reservation
  
  validates_presence_of :amount
  
  attr_accessor :credit_card_type,
                :credit_card_number,
                :credit_card_expiration_month,
                :credit_card_expiration_year,
                :credit_card_verification,
                :credit_card_first_name,
                :credit_card_last_name,
                :credit_card_address,
                :credit_card_city,
                :credit_card_state,
                :credit_card_zip

  if Rails.env.production?
    ActiveMerchant::Billing::Base.mode = :production
    LOGIN_ID =        ENV['AUTHORIZE_NET_LOGIN_ID']
    TRANSACTION_KEY = ENV['AUTHORIZE_NET_TRANSACTION_KEY']
  else
    ActiveMerchant::Billing::Base.mode = :test
    LOGIN_ID = '44eYUR5Uy7nn'
    TRANSACTION_KEY = '24V8H5aqzgT792Hq'
  end
    
  def card_valid?
    @credit_card = ActiveMerchant::Billing::CreditCard.new(
      :number => @credit_card_number,
      :month => @credit_card_expiration_month,
      :year => @credit_card_expiration_year,
      :first_name => @credit_card_first_name,
      :last_name => @credit_card_last_name,
      :verification_value => @credit_card_verification,
      :type => @credit_card_type,
      )
    return true if @credit_card.valid?
    @credit_card.errors.full_messages{|m| errors.add_to_base(m)
  end

  def name_and_address
    {
      :email => patron.email,
      :billing_address => {
        :name     => "#{@credit_card_first_name} #{@credit_card_last_name}",
        :address1 => @credit_card_address,
        :city     => @credit_card_city,
        :state    => @credit_card_state,
        :country  => "US",
        :zip      => @credit_card_zip
      }
    }
  end

  # Returns a 2-element array:
  #   [successful?, transaction ID (string) or error message if payment unsuccessful]
  def process_payment

    raise 'invalid credit card' unless @credit_card && @credit_card.valid?
    
    gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new(
      :login => LOGIN_ID,
      :password => TRANSACTION_KEY
      )

    description = "Concerts in the Clearing"
    if reservation
      description += "/Tickets, #{reservation.concert.name}"
    end

    response = gateway.purchase((amount * 100).to_i, @credit_card, name_and_address.merge({:description => description}))
    return [true, response.authorization] if response.success?
    return [false, response.message]
    
  end

  # Fair market value of the tickets received for a donation is the product
  # of the number of tickets reserved and the suggested donation per ticket.
  #
  # Returns BigDecimal.
  def fair_market_value_of_tickets
    return BigDecimal.new('0.0') unless reservation && reservation.number_of_tickets
    return BigDecimal.new(reservation.number_of_tickets.to_s) * concert.suggested_ticket_donation
  end

end
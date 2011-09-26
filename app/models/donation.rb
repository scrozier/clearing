class Donation < ActiveRecord::Base

  belongs_to :patron
  validates :patron_id, :presence => true
  
  belongs_to :concert
  
  attr_accessor :credit_card_type,
                :credit_card_number,
                :credit_card_expiration_month,
                :credit_card_expiration_year,
                :credit_card_verification,
                :credit_card_first_name,
                :credit_card_last_name,
                :amount

  if Rails.env.production?
    LOGIN_ID =        ENV['AUTHORIZE_NET_LOGIN_ID']
    TRANSACTION_KEY = ENV['AUTHORIZE_NET_TRANSACTION_KEY']
  else
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
      :type => @credit_card_type
      )
    @credit_card.valid?
  end
  
  # Returns a 2-element array:
  #   [successful?, transaction ID (string) or error message if payment unsuccessful]
  def process_payment

    # for testing
    ActiveMerchant::Billing::Base.mode = :test
    
    raise 'invalid credit card' unless @credit_card && @credit_card.valid?
    
    gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new(
      :login => LOGIN_ID,
      :password => TRANSACTION_KEY
      )

    response = gateway.purchase((@amount * 100).to_i, @credit_card)
    return [true, response.authorization] if response.success?
    return [false, response.message]
    
  end

end
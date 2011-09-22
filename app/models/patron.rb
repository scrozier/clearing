class Patron < ActiveRecord::Base

  validates_presence_of :first_name, :last_name, :email
  validates_confirmation_of :email
  validates_uniqueness_of :email
  
  has_many :reservations

  def full_name
    "#{first_name} #{last_name}"
  end
  
end
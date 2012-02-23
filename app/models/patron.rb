class Patron < ActiveRecord::Base

  validates_presence_of :first_name, :last_name, :email
  validates_confirmation_of :email
  validates_uniqueness_of :email
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  
  has_many :reservations
  has_many :donations

  def full_name
    "#{first_name} #{last_name}"
  end
  
end
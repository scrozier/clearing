class Reservation < ActiveRecord::Base

  validates_presence_of :patron_id
  
  belongs_to :patron
  belongs_to :concert
  
  has_one :donation

end
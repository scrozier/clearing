class Concert < ActiveRecord::Base

  has_many :reservations

  validates_presence_of :name, :date_and_time, :ident_string
  validates_uniqueness_of :ident_string, :name

end

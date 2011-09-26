class AddReservationAssociationToDonation < ActiveRecord::Migration
  def self.up
    add_column :donations, :reservation_id, :integer
  end

  def self.down
    remove_column :donations, :reservation_id
  end
end
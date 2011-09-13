class FixPatronRefInReservations < ActiveRecord::Migration
  def self.up
    rename_column :reservations, :patrons_id, :patron_id
  end

  def self.down
    rename_column :reservations, :patron_id, :patrons_id
  end
end
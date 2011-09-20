class AddSingleUseTokenToReservation < ActiveRecord::Migration
  def self.up
    add_column :reservations, :unique_token, :string
  end

  def self.down
    remove_column :reservations, :unique_token
  end
end
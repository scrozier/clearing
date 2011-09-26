class AddSuggestedTicketDonation < ActiveRecord::Migration
  def self.up
    add_column :concerts, :suggested_ticket_donation, :integer
  end

  def self.down
    remove_column :concerts, :suggested_ticket_donation
  end
end
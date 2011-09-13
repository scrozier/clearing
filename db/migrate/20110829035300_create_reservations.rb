class CreateReservations < ActiveRecord::Migration
  def self.up
    create_table :reservations, :force => true do |t|
      t.integer :number_of_tickets
      t.references :patrons
      t.timestamps
    end
  end

  def self.down
    drop_table :reservations
  end
end
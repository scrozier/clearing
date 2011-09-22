class AddDonations < ActiveRecord::Migration
  def self.up
    create_table :donations, :force => true do |t|
      t.integer :patron_id
      t.integer :concert_id
      t.decimal :amount, :precision => 8, :scale => 2
      t.string :credit_card_ends_with
      t.string :transaction_code
      t.timestamps
    end
  end

  def self.down
    drop_table :donations
  end
end
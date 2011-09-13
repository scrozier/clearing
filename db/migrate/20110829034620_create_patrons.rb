class CreatePatrons < ActiveRecord::Migration
  def self.up
    create_table :patrons, :force => true do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.timestamps
    end
  end

  def self.down
    drop_table :patrons
  end
end
class CreateConcerts < ActiveRecord::Migration
  def self.up
    create_table :concerts, :force => true do |t|
      t.string :name
      t.datetime :date_and_time
      t.string :ident_string
      t.timestamps
    end
    
    add_column :reservations, :concert_id, :integer
  end

  def self.down
    remove_column :reservations, :concert_id
    drop_table :concerts
  end
end
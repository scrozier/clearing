class AddInMemoriumFieldsToDonation < ActiveRecord::Migration
  def self.up
    add_column :reservations, :in_memory_of, :string
    add_column :reservations, :in_memory_by, :string
  end

  def self.down
    remove_column :reservations, :in_memory_by
    remove_column :reservations, :in_memory_of
  end
end
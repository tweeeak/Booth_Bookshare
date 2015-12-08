class Changepricestonumber < ActiveRecord::Migration
  def change
    change_column :listings,  :price,  :integer
    change_column :wishlists, :price,  :integer
    change_column :interests, :prop_price,  :integer
  end
end

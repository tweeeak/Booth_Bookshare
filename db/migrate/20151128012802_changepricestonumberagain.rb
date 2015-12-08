class Changepricestonumberagain < ActiveRecord::Migration
  def change
    change_column :listings,  :price,  :decimal
    change_column :wishlists, :price,  :decimal
    change_column :interests, :prop_price,  :decimal
  end
end

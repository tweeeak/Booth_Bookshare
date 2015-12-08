class CreateWishlists < ActiveRecord::Migration
  def change
    create_table :wishlists do |t|
      t.string :status_id
      t.string :price
      t.string :sale_rent
      t.integer :user_id
      t.integer :book_id

      t.timestamps

    end
  end
end

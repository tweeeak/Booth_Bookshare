class CreateInterests < ActiveRecord::Migration
  def change
    create_table :interests do |t|
      t.string :status_id
      t.string :prop_price
      t.integer :user_id
      t.integer :listing_id

      t.timestamps

    end
  end
end

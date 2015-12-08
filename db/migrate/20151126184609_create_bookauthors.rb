class CreateBookauthors < ActiveRecord::Migration
  def change
    create_table :bookauthors do |t|
      t.string :author_id
      t.string :book_id

      t.timestamps null: false
    end
  end
end

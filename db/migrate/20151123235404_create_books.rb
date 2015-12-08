class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :description
      t.string :publisher
      t.string :isbn13
      t.string :artwork
      t.integer :subject_id
      t.string :year
      t.string :title
      t.string :isbn10

      t.timestamps

    end
  end
end

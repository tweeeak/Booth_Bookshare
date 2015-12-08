class Wishlist < ActiveRecord::Base
  belongs_to :status
  belongs_to :book , :class_name => "Book", :foreign_key => "book_id"
  belongs_to :user , :class_name => "User", :foreign_key => "user_id"

  has_many :listings, :class_name => "Listing", :foreign_key => "book_id", :primary_key => "book_id"
end

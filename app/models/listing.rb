class Listing < ActiveRecord::Base
 validates :user_id,    :presence => true
 validates :book_id,    :presence => true
 validates :sale_rent,  :presence => true
 validates :price,      :presence => true
 validates :status_id,  :presence => true

 has_many :interests , :class_name => "Interest", :foreign_key => "listing_id"
 has_many :wishlists , :class_name => "Wishlist", :foreign_key => "book_id", :primary_key => "book_id"
 belongs_to :status
 belongs_to :book , :class_name => "Book", :foreign_key => "book_id"
 belongs_to :user , :class_name => "User", :foreign_key => "user_id"
end

class Wishlist < ActiveRecord::Base
  validates :user_id,    :presence => true
  validates :book_id,    :presence => true
  validates :sale_rent,  :presence => true
  validates :price,      :presence => true
  validates :status_id,  :presence => true

  belongs_to :status
  belongs_to :book , :class_name => "Book", :foreign_key => "book_id"
  belongs_to :user , :class_name => "User", :foreign_key => "user_id"

  has_many :listings, :class_name => "Listing", :foreign_key => "book_id", :primary_key => "book_id"
end

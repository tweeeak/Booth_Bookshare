class Book < ActiveRecord::Base

  validates :isbn13, :presence => true, :uniqueness => true
  #Check what happens when there is none.
  validates :isbn10, :uniqueness => true
  validates :subject_id, :presence => true
  validates :title, :presence => true

	has_many :wishlists , :class_name => "Wishlist", :foreign_key => "book_id", :dependent => :destroy
  has_many :listings , :class_name => "Listing", :foreign_key => "book_id", :dependent => :destroy
  has_many :bookauthors, :dependent => :destroy
  has_many :authors , :through => :bookauthors
  belongs_to :subject , :class_name => "Subject", :foreign_key => "subject_id"

end

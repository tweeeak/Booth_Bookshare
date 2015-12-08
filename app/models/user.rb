class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable

  validates :username, :presence => true, :uniqueness => true

  has_many :interests , :class_name => "Interest", :foreign_key => "user_id"
  has_many :wishlists , :class_name => "Wishlist", :foreign_key => "user_id"
  has_many :listings , :class_name => "Listing", :foreign_key => "user_id"

  has_many :surrogate_listings, :through => :interests, :source => :listing
  has_many :books, :through => :surrogate_listings
end

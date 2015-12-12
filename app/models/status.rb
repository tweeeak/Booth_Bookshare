class Status < ActiveRecord::Base
   validates :status,    :presence => true, :uniqueness => true

   has_many :listings
   has_many :wishlists
   has_many :interests
end

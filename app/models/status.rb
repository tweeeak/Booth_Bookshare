class Status < ActiveRecord::Base
   has_many :listings
   has_many :wishlists
   has_many :interests
end

class Interest < ActiveRecord::Base
 belongs_to :listing , :class_name => "Listing", :foreign_key => "listing_id"
 has_one :book, :through => :listing
 belongs_to :user , :class_name => "User", :foreign_key => "user_id"
 belongs_to :status
end

class Bookauthor < ActiveRecord::Base
	validates :author_id, :presence => true, uniqueness: { scope: :book_id}

  belongs_to :author
end

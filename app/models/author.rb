class Author < ActiveRecord::Base
  validates :author_name, :presence => true, :uniqueness => true

  has_many :bookauthors
end

class Subject < ActiveRecord::Base
  validates :subject_number, :presence => true, :uniqueness => true
  validates :subject_name, :presence => true

  has_many :books , :class_name => "Book", :foreign_key => "subject_id"
end

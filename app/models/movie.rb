class Movie < ActiveRecord::Base
	has_many :movie_locations
	has_many :locations, :through => :movie_locations
	validates_uniqueness_of :code
end

class User < ActiveRecord::Base
	has_one :user_movie_location
end

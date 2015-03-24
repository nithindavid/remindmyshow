class HomeController < ApplicationController

	def index

	end

	def create
		user_movie_location_params = {
					:user_id => (User.find_or_create_by(:email => params.delete(:email))).id,
					:movie_location_id => (MovieLocation.find_or_create_by(create_associations(params))).id
				 }

		UserMovieLocation.find_or_create_by(user_movie_location_params)

		render :nothing => true
	end

	private

	def create_associations(params)
		{
			:movie_id => (Movie.find_by :name => params[:movie_name]).id,
			:location_id => (Location.find_by :name => params[:location]).id
		}

	end

end

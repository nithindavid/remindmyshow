require 'nokogiri'
require 'open-uri'
require 'json'

URL_LIST = {
		:coming_soon => "http://in.bookmyshow.com/movies/comingsoon/",
		:locations => 'http://in.bookmyshow.com/getJSData/?cmd=GETREGIONS'
}

namespace :populate_data do
  desc "TODO"

  def open_url(url)
  	Nokogiri::HTML(open(url))
  end

  task populate_movies: :environment do

  	def find_movie_code selector
		selector.css('a').attribute('href').to_s.split('/')[3].strip
	end

	def find_movie_link selector
		selector.css('a').attribute('href').to_s.split('/')[2].strip
	end

	def find_movie_name selector
		selector.css('a').text.strip
	end

  	doc = open_url(URL_LIST[:coming_soon])

	doc.css('.mlist').each do |movie|

		element = movie.at_css('.listhd')
		release_date =  Time.parse(movie.at_css('.dtblock')).utc rescue nil

		movie_params =  {
							:code => (find_movie_code element),
							:name => (find_movie_name element),
							:link => (find_movie_link element),
							:release_date => release_date
				 	   }

		movie = Movie.find_by_code(movie_params[:code])
		unless movie 
			Movie.create(movie_params)
		else
			movie.update_attribute(:release_date,movie_params[:release_date]) unless movie.release_date != movie_params[:release_date]
		end
	end

  end

  task populate_locations: :environment do

	response = open_url(URL_LIST[:locations])

	region_list = (response.to_s.match /.*regionlst=(.*);var regionalias=.*/).captures[0]

	list_json =  JSON.parse(region_list)

	list_json.keys.each do |key|
		list_json[key].each do |value|
			location_params = {
								:name => (value["name"]),
								:code => (value["code"])
							  }
			Location.create(location_params)
		end
	end
	
  end

  task run_sidekiq: :environment do
  	EmailNotifierWorker.perform_async(nil)
  end
end

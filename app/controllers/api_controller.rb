class ApiController < ApplicationController
  	respond_to :json


  	#search in all resources
  	def search
  		render :json => "{\"results\":[]}"
  	end

  	# http://rubydoc.info/github/janko-m/flickrie/master
  	# http://www.flickr.com/services/api/
	def flickr
		require 'flickrie'

		Flickrie.api_key = "9a9457aa5a5c1cc9b2a243a82a6a1dd5"
		Flickrie.shared_secret = "093b1e94fea1a0d8"

		result = Flickrie.search_photos(tags: params[:search])
		photos = []
		result[0..10].each do |r|
			photos << Flickrie.get_photo_info(r.id)
		end

		render :json => photos
	end

	def facebook
		render :json => "{\"results\":[]}"
	end

	def twitter
		render :json => "{\"results\":[]}"
	end

	def wikipedia
		render :json => "{\"results\":[]}"
	end
end

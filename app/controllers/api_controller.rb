class ApiController < ApplicationController
  	respond_to :json
  	before_filter :validate_params


  	#search in all resources
  	def search
  		@limit = params[:limit] ? params[:limit] : 10
  		if @error
  			result = @error
  		else
  			if params[:resource]
  				result = self.send(params[:resource])
  			else
	  			result = {
	  				flickr: flickr,
	  				facebook: facebook,
	  				twitter: twitter,
	  				wikipedia: wikipedia
	  			} 
	  		end
  		end
  		render :json => {result: result}
  	end

	def flickr
		require 'flickrie'
		Flickrie.api_key = "9a9457aa5a5c1cc9b2a243a82a6a1dd5"
		Flickrie.shared_secret = "093b1e94fea1a0d8"

		query = params[:search]
		result = Flickrie.search_photos(tags: query, text:query)

		photos = []
		result[0..@limit].each do |r|
			info = Flickrie.get_photo_info(r.id)
			photos << {
				title: info.title, 
				description: info.description, 
				owner: info.owner.hash, 
				location:info['location'].hash,
				date_posted: info['dates']['posted'],
				date_taken: info['dates']['taken'],
				url: info['urls']['url'],
				type: info['media'],
				comments_count: info.comments_count,
				location: info.location
			}
		end
		photos
	end

	def facebook
		[]
	end

	def twitter
		# require 'twitter'
		# client = Twitter::REST::Client.new do |config|
		#   config.consumer_key        = "jrQQLPvLRzJ9lLf6pd8r3Q"
		#   config.consumer_secret     = "s5ylJSbIyX8t51bZIZY14hTwVFoG9k3SIUPbe6cNJo"
		#   config.bearer_token        = "AAAAAAAAAAAAAAAAAAAAAIAETwAAAAAAgWaQPsghbCxRF5NAl%2FdfiagCVaE%3DjQ4CHqMZP6LwfWFmeARDgL0uTVD5x184l2UivAVGR5I2LkumrU"
		# end

		# tweets = []
		# topics = params[:search]
		# raise client.inspect
		# client.filter(:track => topics) do |object|
		#   tweets << object.text if object.is_a?(Twitter::Tweet)
		# end
		# tweets
		[]
	end

	def wikipedia
		[]
	end

	private

		# checks if resource exists and search query is long enough
		def validate_params
			if params[:resource] && !(self.respond_to? params[:resource])
				@error = "Resource invalid"
			elsif params[:search] && params[:search].length < 3
				@error = "Please enter a searchword longer than 2 characters"
			end
		end
end

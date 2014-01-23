class ApiController < ApplicationController
	respond_to :json
	before_filter :validate_params


	#search in all resources
	def search
		@limit = params[:limit] ? params[:limit].to_i : 10
		if @error
			@result = @error
		else
			if params[:resource]
				@result = self.send(params[:resource])
			else
				@result = {
					flickr: flickr,
					instagram: instagram,
	  				facebook: facebook,
	  				twitter: twitter,
	  				youtube: youtube,
	  				wikipedia: wikipedia
  				}
  			end
  		end
	  	respond_to do |format|
	  		format.json { render :json => {result: @result} }
	  		format.html { render :partial => (params[:resource] ? params[:resource] : "search"), locals: { result: @result} }
	  	end
	end

	def flickr
		# require 'flickrie'
		Flickrie.api_key = ENV['FLICKR_API_KEY']
		Flickrie.shared_secret = ENV['FLICKR_SHARED_SECRET']

		query = params[:search]
		result = Flickrie.search_photos(tags: query.split(' '), text:query)
		@limit = result.length if result.length < @limit

		photos = []
		result[0..@limit].each do |r|
			info = Flickrie.get_photo_info(r.id)
			photos << FlickrPhoto.new(info)
		end
		photos
	end

	def facebook
		[]
	end

	def twitter
		#require 'twitter'

		client = Twitter::REST::Client.new do |config|
			config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
			config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
			config.bearer_token        = ENV['TWITTER_BEARER_TOKEN']
		end

		tweets = []
		topics = params[:search]

		client.search(topics, :count => 3, :result_type => "recent").take(@limit).collect do |tweet|
			#raise tweet.url.inspect
			# puts tweet.text
			tweets << Tweet.new(tweet) # {content: tweet.text, user: tweet.user.screen_name, datetime: tweet.created_at, url: twitter_url(tweet), id: tweet.id}
			#Tweet.new(tweet.text, tweet.user.screen_name, tweet.id, tweet.created_at)
		end
		tweets
	end

	def wikipedia
		[]
	end

	def instagram
		photos = []

		result = Instagram.tag_search(params[:search])
		@limit = result.length if result.length < @limit
		result[0..2].each do |tag|
			tag_media = Instagram.tag_recent_media(tag['name'])
			tag_media[0..@limit].each do |media|
				media['type'] = "media"
				photos << InstagramPhoto.new(media)
			end
		end

		result = Instagram.user_search(params[:search])
		limit = result.length < 2 ? result.length : 2
		result[0..limit].each do |r|
			r['type'] = "user"
			photos << r
			user_media = Instagram.user_recent_media(777)
			limit = user_media.length < 2 ? user_media.length : 2
			user_media[0..limit].each do |media|
				media['type'] = "user_media"
				photos << InstagramPhoto.new(media)
			end
		end

		photos
	end

	def youtube
		require 'google/api_client'

		client = Google::APIClient.new

		youtube = client.discovered_api('youtube', 'v3')

		client.authorization = nil

		res = client.execute :key => ENV['GOOGLE_API_KEY'], :api_method => youtube.search.list, :parameters => {:part => 'id,snippet', :q => params[:search], :maxResults => 10}

		result = JSON.parse(res.data.to_json)

		results = []

		result['items'].each do |r|
			results << YoutubeResult.new(r)
		end

		results
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

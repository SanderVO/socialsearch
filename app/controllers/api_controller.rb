class ApiController < ApplicationController
	respond_to :json
	before_filter :validate_params

	#search in all resources
	def search
		@limit = params[:limit] ? params[:limit].to_i : 10
		if @error
			@result = @error
		else
			if params[:provider]
				@result = self.send(params[:provider])
			else
				@result = {
					flickr: flickr,
					tumblr: tumblr,
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
	  		format.html { render :partial => (params[:provider] ? params[:provider] : "search"), locals: { result: @result} }
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

		return_result limit: @limit, items: photos
	end

	def facebook
		return_result items: []
	end

	def tumblr
		require 'tumblr_client'

		client = Tumblr::Client.new

		tumblrs = []
		tags = params[:search]
		photo_url = ''

		error = nil
		
		client.tagged(tags, :limit => 5).each do |blog|
			if blog.first == "status" || blog.first == "msg"
				error = blog.last
			else
				tumblrs << TumblrBlog.new(blog)
			end
		end
		
		if error
			return_result status: error
		else
			return_result items: tumblrs
		end
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
			tweets << Tweet.new(tweet)
		end
		tweets

		return_result items: tweets
	end

	def wikipedia
		return_result items: []
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

		return_result items: photos
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

		return_result total_count: 15, items: results
	end

	private

	def return_result params
		result = {}
		params.each do |k,v|
			result[k] = v;
		end
		result
	end
	# checks if provider exists and search query is long enough
	def validate_params
		if params[:provider] && !(self.respond_to? params[:provider])
			@error = "Resource invalid"
		elsif !params[:search] || (params[:search] && params[:search].length < 3)
			@error = "Please enter a searchword longer than 2 characters"
		end
	end
end

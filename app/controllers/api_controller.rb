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
					tumblr: tumblr
  				#facebook: facebook,
  				#twitter: twitter
  				#wikipedia: wikipedia
  			}
  		end
  	end
  	respond_to do |format|
  		format.json { render :json => {result: @result} }
  		format.html { render :partial => (params[:resource] ? params[:resource] : "search"), locals: { result: @result} }
  	end
  end

	def flickr
		require 'flickrie'
		Flickrie.api_key = ENV['FLICKR_API_KEY']
		Flickrie.shared_secret = ENV['FLICKR_SHARED_SECRET']

		query = params[:search]
		result = Flickrie.search_photos(tags: query.split(' '), text:query)
		@limit = result.length if result.length < @limit

		photos = []
		result[0..@limit].each do |r|
			info = Flickrie.get_photo_info(r.id)
			photos << FlickrPhoto.new(info.title, info.description, info.owner.username, info.location, info.url, info["dates"]["posted"], "http://farm#{info.farm}.staticflickr.com/#{info.server}/#{info.id}_#{info.secret}.jpg")
		end
		photos
	end

	def facebook
		[]
	end

	def tumblr
		require 'tumblr_client'

		Tumblr.configure do |config|
		  config.consumer_key = ENV['TUMBLR_CONSUMER_KEY']
		  config.consumer_secret = ENV['TUMBLR_CONSUMER_SECRET']
		end

		client = Tumblr::Client.new

		tumblrs = []
		tags = params[:search]
		photo_url = ''

		client.tagged(tags, :limit => 5).each do |blog|
			if blog['photos'] != nil
				blog['photos'].each do |photo|
					photo_url = photo['alt_sizes'].first['url']
				end
			end
			tumblrs << TumblrPhoto.new(blog['blog_name'], blog['date'], blog['post_url'], photo_url, blog['caption'])
		end
		tumblrs
	end

	def twitter
		require 'twitter'

		client = Twitter::REST::Client.new do |config|
			config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
			config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
			config.bearer_token        = ENV['TWITTER_BEARER_TOKEN']
		end

		tweets = []
		topics = params[:search]

		client.search(topics, :count => 30, :result_type => "recent").results.map do |tweet|
			puts tweet.text
			tweets << Tweet.new(tweet.text, tweet.user.screen_name, tweet.id, tweet.created_at)
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
				media['likes'] = media['likes']['count']
				media['tags'] = media['tags'].length
				media['comments'] = media['comments']['count']
				photos << media
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
				media['username'] = "username"
				media['likes'] = media['likes']['count']
				media['tags'] = media['tags'].length
				media['comments'] = media['comments']['count']
				photos << media
			end
		end

		photos
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

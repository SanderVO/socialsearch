class ApiController < ApplicationController
	#doorkeeper_for :all, :if => lambda { request.format == "json" }
	respond_to :json
	before_filter :validate_params

	#search in all resources
	def search
		@limit = params[:limit] ? params[:limit].to_i : 20
		if @error
			@result = @error
		else

			# store search
			if current_user && params[:provider]
				@search = Search.where(user: current_user, query: params[:search], :created_at.gt => Time.now-15.seconds).first
				if @search
					@search.providers
					@search.providers << params[:provider]
					@search.providers.uniq!
					@search.save
				else
					new_search = true
				end
			else
				new_search = true
			end

			if new_search
				@search = Search.new(query: params[:search])
				@search.user = current_user if current_user
				@search.providers = params[:provider] ? [params[:provider]] : []
				@search.save
			end


			if params[:provider]
				@result = {}
				@result["#{params[:provider]}"] = self.send(params[:provider])
			else
				@result = {
					flickr: flickr,
					tumblr: tumblr,
					instagram: instagram,
	  			twitter: twitter,
	  			youtube: youtube,
	  			wikipedia: wikipedia,
	  			googleplus: googleplus,
	  			facebook: facebook
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
		Flickr.api_key = ENV['FLICKR_API_KEY']
		Flickr.shared_secret = ENV['FLICKR_SHARED_SECRET']

		query = params[:search]
		text_result = Flickr.photos.search(text:query)
		tag_result = Flickr.photos.search(tags: query)
		text_limit = @limit
		text_limit = text_result.length if text_result.length < @limit
		text_limit -= (tag_result.length <= @limit/2) ? tag_result.length : @limit/2
		tag_limit = @limit - text_limit
		tag_limit = tag_result.length if tag_limit > tag_result.length

		# raise [text_limit,tag_limit].inspect
		text_limit -= 1
		photos = []
		text_result[0..text_limit].each do |r|
			info = Flickr.photos.get_info(r.id)
			photos << FlickrPhoto.new(info)
		end
		# raise photos.length.inspect

		tag_limit -= 1
		tag_result[0..tag_limit].each do |r|
			info = Flickr.photos.get_info(r.id)
			photos << FlickrPhoto.new(info)
		end
		return_result limit: @limit, items: photos
	end

	def facebook
		facebook_posts = []

		if session[:fb_token]
			query = params[:search]

			graph = Koala::Facebook::API.new(session[:fb_token])

			results = graph.search(query)

			results.each do |result|
				facebook_posts << Facebook.new(result)
			end
		end

		return_result items: facebook_posts
	end

	def tumblr
		require 'tumblr_client'

		client = Tumblr::Client.new

		tumblrs = []
		tags = params[:search]
		photo_url = ''

		error = nil

		client.tagged(tags, :limit => @limit, :filter => "raw", :before => (params[:nextpagetoken] ? params[:nextpagetoken] : '')).each do |blog|
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

		client.search(topics, :count => @limit, :result_type => "recent", :max_id => (params[:nextpagetoken] ? params[:nextpagetoken] : '')).take(@limit).collect do |tweet|
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
		tag_limit = 2
		result = []
		tags = ((params[:search].include? " ") ? params[:search].split(' ') : [params[:search]] )
		tags.each do |t|
			result = Instagram.tag_search(t)
		end
				
		debug = []
		tag_limit = result.length if result.length < tag_limit
		debug << "found #{result.length} tags"
		result[0..tag_limit].each do |tag|
			tag_media = Instagram.tag_recent_media(tag['name'], {:max_id => (params[:nextpagetoken] ? params[:nextpagetoken] : '')})
			@max_id = tag_media.pagination.next_max_tag_id
			limit = (result.length > 1 ? (@limit/2) : @limit)
			limit = tag_media.length if tag_media.length < limit
			limit -= 1
			tag_media[0..limit].each do |media|
				media['type'] = "media"
				photos << InstagramPhoto.new(media)
				debug << "image from tag #{tag}"
			end
		end

		# result = Instagram.user_search(params[:search])
		# limit = result.length < 2 ? result.length : 2
		# result[0..limit].each do |r|
		# 	r['type'] = "user"
		# 	photos << r
		# 	user_media = Instagram.user_recent_media(r['id'])
		# 	limit = user_media.length < 2 ? user_media.length : 2
		# 	user_media[0..limit].each do |media|
		# 		media['type'] = "user_media"

		# 		photos << InstagramPhoto.new(media)
		# 	end
		# end

		return_result pagetoken: @max_id, items: photos
	end

	def youtube
		require 'google/api_client'

		client = Google::APIClient.new

		youtube = client.discovered_api('youtube', 'v3')

		client.authorization = nil

		res = client.execute :key => ENV['GOOGLE_API_KEY'], :api_method => youtube.search.list, :parameters => {:part => 'id,snippet', :q => params[:search], :maxResults => 20, :pageToken => (params[:nextpagetoken] ? params[:nextpagetoken] : '')}

		result = JSON.parse(res.data.to_json)

		results = []

		result['items'].each do |r|
			results << YoutubeResult.new(r)
		end

		return_result page_token: result['nextPageToken'], items: results
	end

	def googleplus
		require 'google/api_client'

		client = Google::APIClient.new
		plus = client.discovered_api('plus', 'v1')
		client.authorization = nil;

		results = []

		res = client.execute :key => ENV['GOOGLE_API_KEY'], :api_method => plus.people.search, :parameters => {:query => params[:search], :maxResults => 20, :pageToken => (params[:nextpagetoken] ? params[:nextpagetoken] : '')}
		res2 = client.execute :key => ENV['GOOGLE_API_KEY'], :api_method => plus.activities.search, :parameters => {:query => params[:search], :maxResults => 20, :pageToken => (params[:secondtoken] ? params[:secondtoken] : '')}

		people = JSON.parse(res.data.to_json)
		activities = JSON.parse(res2.data.to_json)

		people['items'].each do |p|
			results << GoogleProfile.new(p)
		end

		activities['items'].each do |a|
			results << GoogleActivity.new(a)
		end

		return_result page_token: people['nextPageToken'], second_token: activities['nextPageToken'], items: results
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

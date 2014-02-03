class Tweet < Result

  attr_reader :id, :image, :name

  def initialize(tweet)
    super(tweet.created_at, tweet.text, tweet.user.screen_name, tweet_url(tweet))
    @image = tweet['user']['profile_image_url']
    @name = tweet.user.name
    @id = tweet.id
  end

  private 
	  def tweet_url tweet
		tweet.url.scheme + "://" + tweet.url.host + tweet.url.path
	  end
end

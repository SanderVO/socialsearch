class Tweet < Result

  def initialize(tweet)
    super(tweet.created_at, tweet.text, tweet.user.screen_name, tweet_url(tweet))
  end

  private 
	  def tweet_url tweet
		tweet.url.scheme + "://" + tweet.url.host + tweet.url.path
	  end
end

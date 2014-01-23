class Tweet < Result
  BASIC_URL = "https://twitter.com/"
  def initialize(tweet)
    super(tweet.datetime, tweet.content, tweet.username, tweet_url(tweet))
  end

  private 
	  def tweet_url tweet
		tweet.url.scheme + "://" + tweet.url.host + twitter.url.path
	  end
end

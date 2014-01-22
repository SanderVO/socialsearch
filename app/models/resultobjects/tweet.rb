class Tweet
  attr_reader :text, :username
  BASIC_URL = "https://twitter.com/"
  def initialize(text, username, id)
    @text = text
    @username = username
    @url = "#{BASIC_URL}#{username}/#{id}"
  end
end

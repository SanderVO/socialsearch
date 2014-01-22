class Tweet < Result
  BASIC_URL = "https://twitter.com/"
  def initialize(content, username, datetime, id)
    super(datetime, content, username, "#{BASIC_URL}#{username}/#{id}")
  end
end

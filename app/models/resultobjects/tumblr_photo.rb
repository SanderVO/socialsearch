class TumblrPhoto < Result
  attr_reader :caption
  def initialize(username, datetime, url, content, caption)
    super(datetime, content, username, url)
    @caption = caption
  end
end

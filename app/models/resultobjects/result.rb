class Result
  attr_reader :content, :datetime, :username, :url
  def initialize(datetime, content, username, url)
    @content = content
    @datetime = datetime
    @username = username
    @url = url
  end
end

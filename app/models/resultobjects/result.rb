class Result
  attr_reader :content, :datetime, :username
  def initialize(datetime, content, username, url)
    @content = content
    @datetime = datetime
    @username = username
  end
end

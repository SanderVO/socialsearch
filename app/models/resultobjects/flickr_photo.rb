class FlickrPhoto < Result
  def initialize(title, description, username, location, url, datetime, content)
    super(datetime, content, username, url)
    @title = title
    @description = description
    @location = location
  end
end

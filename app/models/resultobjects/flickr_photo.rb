class FlickrPhoto < Result
  attr_reader :title, :description, :location

  def initialize(info)
    super(info["dates"]["posted"], "http://farm#{info.farm}.staticflickr.com/#{info.server}/#{info.id}_#{info.secret}.jpg", info.owner.username, info.url)
    @title = info.title
    @description = info.description
    @location = info.location
  end
end

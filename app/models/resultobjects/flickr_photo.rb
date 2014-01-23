class FlickrPhoto < Result
  attr_reader :title, :description, :location

  def initialize(info)
    super(info["dates"]["posted"], "http://farm#{info.farm}.staticflickr.com/#{info.server}/#{info.id}_#{info.secret}.jpg", info.owner.username, info.url)
    @title = info.title
    @description = info.description
    if info.location != nil
	    @location = {lat: info.location['latitude'], lon: info.location['longitude'], place: get_place(info.location) }
	end
  end

  def get_place location
  	location['locality']['_content']+ ", "+ location['region']['_content']+ ", "+ location['country']['_content']
  end
end

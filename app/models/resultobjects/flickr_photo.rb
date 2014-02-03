class FlickrPhoto < Result
  attr_reader :title, :description, :location

  def initialize(info)
    super(info["dates"]["posted"], "http://farm#{info.farm}.staticflickr.com/#{info.server}/#{info.id}_#{info.secret}.jpg", info.owner.username, info.url)
    @title = info.title
    @description = info.description
    
    if info.location
	    @location = {lat: info.location['latitude'], lon: info.location['longitude'], place: get_place(info.location) }
	  end
  end

  def get_place location
    result = ""
    result += location['locality']['_content']+", " if location['locality']
    result += location['region']['_content']+", " if location['region']
    result += location['country']['_content'] if location['country']
  	result

  end
end

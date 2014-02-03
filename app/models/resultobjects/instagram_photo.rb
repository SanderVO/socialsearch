class InstagramPhoto < Result
  attr_reader :title, :comments, :likes, :tags, :type, :images, :pagetoken

  def initialize(info)
   # super(info["dates"]["posted"], "http://farm#{info.farm}.staticflickr.com/#{info.server}/#{info.id}_#{info.secret}.jpg", info.owner.username, info.url)
    super(info.created_time, (info['caption'] ? info['caption']['text'] : ""), (info['user'] ? info['user']['username'] : ""), info['link'])
    @title = info.title
    @likes = info['likes']['count']
	@tags = info['tags'].length
	@comments = info['comments']['count']
	@type = info['type']
	@images = info['images']
  @pagetoken = info['created_time']
  end
end
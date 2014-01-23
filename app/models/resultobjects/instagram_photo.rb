class InstagramPhoto < Result
  attr_reader :title, :comments, :likes, :tags, :type, :images

  def initialize(info)
   # super(info["dates"]["posted"], "http://farm#{info.farm}.staticflickr.com/#{info.server}/#{info.id}_#{info.secret}.jpg", info.owner.username, info.url)
    super(info.created_time, info['caption']['text'], info['user']['username'], info['link'])
    @title = info.title
    @likes = info['likes']['count']
	@tags = info['tags'].length
	@comments = info['comments']['count']
	@type = info['type']
	@images = info['images']
  end
end
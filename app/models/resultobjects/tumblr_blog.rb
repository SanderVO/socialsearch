class TumblrBlog < Result
  attr_reader :caption
  def initialize(info)
  	photo_url = ''
  	if info['type'] == 'photo'
  		info['photos'].each do |photo|
  			photo_url = photo['alt_sizes'].first['url']
  		end
  	end
    super(info['date'], photo_url, info['blog_name'], info['post_url'])
    @caption = info['caption']
  end
end

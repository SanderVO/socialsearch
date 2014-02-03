class TumblrBlog < Result
  attr_reader :caption, :thumbnail, :type, :embed_code, :source_url, :source, :source_title, :text, :title, :body, :player, :id3_title, :question, :answer, :asking_name, :asking_url, :timestamp
  def initialize(info)
  	photo_url = ''
    embed_code = ''

  	if info['type'] == 'photo'
  		info['photos'].each do |photo|
  			photo_url = photo['alt_sizes'].first['url']
  		end
  	elsif info['type'] == 'video'
      embed_code = info['player'].first['embed_code']
    end

    # Photo/General
    super(info['date'], photo_url, info['blog_name'], info['post_url'])
    @caption = info['caption'] == nil ? "" : info['caption'].html_safe
    @caption = info['thumbnail_url']
    # Video
    @type = info['type']
    @embed_code = embed_code
    # Quote
    @source_url = info['source_url'] == nil ? "" : info['source_url']
    @source = info['source']
    @source_title = info['source_title'] == nil ? info['blog_name'] : info['source_title']
    @text = info['text']
    # Text
    @title = info['title']
    @body = info['body']
    # Audio
    @player = info['player']
    @id3_title = info['id3_title']
    # Anwser
    @question = info['question']
    @answer = info['answer']
    @asking_name = info['asking_name']
    @asking_url = info['asking_url']
    @timestamp = info['timestamp']
  end
end

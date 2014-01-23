class GoogleActivity < Result
  attr_reader :title, :type, :image, :profileurl, :profileimage, :attachments

  def initialize(info)
    super(info['published'], info['object']['content'], info['actor']['displayName'], info['url'])
    @title = info['title']
  	@type = info['kind']
  	@image = info['image']['url']
  	@profileurl = info['actor']['url']
  	@profileimage = info['actor']['image']['url']
  	@attachments = info['object']['attachments']
  end
end
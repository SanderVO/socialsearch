class GoogleActivity < Result
  attr_reader :title, :type, :profileurl, :profileimage, :attachments

  def initialize(info)
    super(info['published'], info['object']['content'], info['actor']['displayName'], info['url'])
    @title = info['title']
  	@type = info['kind']
  	@profileurl = info['actor']['url']
  	@profileimage = info['actor']['image']['url']
  	@attachments = info['object']['attachments'] ? info['object']['attachments'] : []
  end
end
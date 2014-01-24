class GoogleProfile < Result
  attr_reader :type, :image

  def initialize(info)
    super("", "", info['displayName'], info['url'])
  	@type = info['kind']
  	@image = info['image']['url']
  end
end
class YoutubeResult < Result
  attr_reader :title, :description, :type, :id, :channelid, :thumbnails

  def initialize(info)
  	if info['id']['kind'] == 'youtube#channel'
  		url = "http://www.youtube.com/user/#{info["snippet"]["channelTitle"]}"
  		@id = info['id']['channelId']
	elsif info['id']['kind'] == 'youtube#playlist'
		url = "http://www.youtube.com/view_play_list?p=#{info["id"]["playlistId"]}"
		@id = info['id']['playlistId']
	else
  		url = "http://www.youtube.com/watch?v=#{info["id"]["videoId"]}"
  		@id = info['id']['videoId']
	end

    super(info["snippet"]['publishedAt'], info["snippet"]['description'], "", url)
    @title = info['snippet']['title']
    @description = info['snippet']['description']
    @type = info['id']['kind']
    @videoid = info['id']['videoId']
    @channelid = info['snippet']['channelId']
    @thumbnails = info['snippet']['thumbnails']
  end
end

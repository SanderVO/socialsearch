class Facebook < Result
  attr_reader :image, :user_image, :user_link

  def initialize(info)
    super(info['created_time'], get_content(info), info['from']['name'], get_url(info['id']))
    @image = info['picture']
    @user_link = get_url(info['from']['id'])
    @user_image = get_user_picture(info['from']['id'])
  end

  def get_url(id)
    "https://www.facebook.com/#{id}"
  end

  def get_user_picture(id)
    "http://graph.facebook.com/#{id}/picture"
  end

  def get_content(info)
    if info['story'] != nil && info['story'] != ""
      info['story']
    elsif info['message'] != nil && info['message'] != nil
      info['message']
    end
  end
end

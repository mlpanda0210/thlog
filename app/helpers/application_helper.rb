module ApplicationHelper

  def profile_img(user)
    unless user.provider.blank?
      img_url = user.picture
    else
      img_url = 'no_image.png'
    end
    image_tag(img_url, alt: user.name)
  end
end

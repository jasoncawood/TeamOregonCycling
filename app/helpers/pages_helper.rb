module PagesHelper
  def leader_bio(name:, title:, email: nil, image: nil, bio: nil)
    render partial: 'leader_bio', locals: {
      name: name, title: title, email: email, image: image, bio: bio
    }
  end
end

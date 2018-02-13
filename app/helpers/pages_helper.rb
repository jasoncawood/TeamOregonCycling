module PagesHelper
  def leader_bio(name:, title:, email: nil, image: nil, bio: nil)
    render partial: 'leader_bio', locals: {
      name: name, title: title, email: email, image: image, bio: bio
    }
  end

  def title_sponsor
    Sponsor.title_sponsor
  end

  def other_sponsors
    Sponsor.other_sponsors
  end
end

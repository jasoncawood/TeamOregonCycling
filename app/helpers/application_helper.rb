module ApplicationHelper
  def main_nav_link(title, url)
    content_tag(:li, class: current_page?(url) ? 'active' : '') do
      link_to title, url
    end
  end
end

module ApplicationHelper
  def main_nav_link(title, url)
    content_tag(:li, class: current_page?(url) ? 'active' : '') do
      link_to title, url
    end
  end

  def page_title(new_value=nil)
    @page_title = new_value unless new_value.nil?
    return nil if @page_title.blank?
    " - #{@page_title}"
  end

  def markdown(text)
    options = {
      filter_html:     true,
      hard_wrap:       true,
      link_attributes: { rel: 'nofollow', target: "_blank" },
      space_after_headers: true,
      fenced_code_blocks: true
    }

    extensions = {
      autolink:           true,
      superscript:        true,
      disable_indented_code_blocks: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(text).html_safe
  end
end

module ApplicationHelper
  include TheHelp::ServiceCaller

  def main_nav_link(title, url, **options)
    content_tag(:li, class: current_page?(url) ? 'active' : '') do
      link_to title, url, **options
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

  def with_permission_to(permission)
    call_service(Services::Authorize, permission: permission,
                 authorized: -> { yield if block_given? },
                 not_authorized: -> {})
  end

  private

  def service_context
    current_user
  end

  def service_logger
    logger
  end
end

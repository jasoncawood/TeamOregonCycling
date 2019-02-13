module ApplicationHelper
  include TheHelp::ServiceCaller

  attr_accessor :body_class, :currently_managing, :admin_heading

  def l_date(date)
    return if date.nil?
    l(date.to_date)
  end

  def managing?(*managables)
    return false if currently_managing.nil?
    managables.include?(currently_managing)
  end

  def main_nav_link(title, url, show_sub: false, **options)
    content_tag(:li, class: (current_page?(url) || show_sub) ? 'active' : '') do
      if block_given? && show_sub
        link_to(title, url, **options) +
          content_tag(:ul, class: 'nav') do
            yield
          end
      else
        link_to(title, url, **options)
      end
    end
  end

  def admin_site_link
    link = nil
    call_service(Admin::DeterminePrimaryAdminScreen,
                 url_generator: method(:url_for),
                 with_result: ->(url) {
                   link = main_nav_link('Admin Site', url)
                 })
    link
  end

  def page_title(new_value=nil)
    @page_title = new_value unless new_value.nil?
    return nil if @page_title.blank?
    " - #{@page_title}"
  end

  def markdown(text, **options)
    default_options = {
      filter_html:     true,
      hard_wrap:       true,
      link_attributes: { rel: 'nofollow', target: "_blank" },
      space_after_headers: true,
      fenced_code_blocks: true
    }

    options = default_options.merge(options)

    extensions = {
      autolink:           true,
      superscript:        true,
      disable_indented_code_blocks: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(text).html_safe
  end

  def with_permission_to(permission, on: nil)
    yield if block_given? && has_permission?(permission, on: on)
  end

  def has_permission?(permission, on: nil)
    permitted = false
    call_service(Authorize, permission: permission, on: on,
                 authorized: -> { permitted = true },
                 not_authorized: -> { permitted = false })
    return permitted
  end

  def recaptcha(action_name)
    content_for :recaptcha_js do
      include_recaptcha_js
    end
    recaptcha_action(action_name)
  end

  def long_date(date)
    date
      .to_date
      .to_formatted_s(:long_ordinal)
  end

  private

  def service_context
    current_user
  end

  def service_logger
    logger
  end
end

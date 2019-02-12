class PagesController < ApplicationController
  KNOWN_PAGES = %w[
    about_us
    sponsors
    code_of_conduct
    join_team
  ]

  def show
    page = params[:id].to_s
    if KNOWN_PAGES.include?(page)
      render action: page
    else
      render_not_found!
    end
  end
end

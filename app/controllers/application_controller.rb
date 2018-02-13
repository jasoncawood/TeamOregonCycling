require 'the_help/service_caller'

class ApplicationController < ActionController::Base
  include TheHelp::ServiceCaller

  protect_from_forgery with: :exception
  before_action :authenticate_user!

  private

  alias service_context current_user
  alias service_logger logger

  def require_permission(permission)
    call_service(Services::Authorize, permission: permission,
                 not_authorized: method(:render_forbidden))
  end

  def render_forbidden
    respond_to do |format|
      format.html do
        render file: "#{Rails.root}/public/403", layout: false,
          status: :forbidden
      end
      format.xml { head :forbidden }
      format.any { head :forbidden }
    end
  end

  def render_404
    respond_to do |format|
      format.html do
        render :file => "#{Rails.root}/public/404", :layout => false,
          :status => :not_found
      end
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end
end

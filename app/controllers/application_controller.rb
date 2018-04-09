class ApplicationController < ActionController::Base
  class RequestHalted < RuntimeError; end

  include TheHelp::ServiceCaller

  protect_from_forgery with: :exception
  around_action :catch_halt
  rescue_from TheHelp::NotAuthorizedError, with: :render_forbidden
  before_action :restore_current_user_from_session

  attr_reader :current_user
  helper_method :current_user

  private

  alias service_context current_user
  alias service_logger logger

  def current_user=(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def restore_current_user_from_session
    call_service(LoadCurrentUser, user_id: session[:user_id],
                 success: method(:current_user=))
  end

  def require_permission(permission)
    call_service(Authorize, permission: permission,
                 not_authorized: method(:render_forbidden))
  end

  def catch_halt
    code = catch(:halt) do
      yield
    end
    unless performed?
      raise RequestHalted,
        'The request was halted before the response was constructed.'
    end
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
    halt!
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
    halt!
  end

  def halt!
    throw :halt
  end
end

class ApplicationController < ActionController::Base
  class RequestHalted < RuntimeError; end

  include TheHelp::ServiceCaller
  include TheHelp::ProvidesCallbacks

  protect_from_forgery with: :exception
  around_action :catch_halt
  before_action :restore_current_user_from_session
  around_action :configure_logging
  rescue_from TheHelp::NotAuthorizedError, with: :render_forbidden
  before_action :check_membership_status

  helper_method :current_user

  class << self
    private

    def require_permission(permission, on: nil)
      before_action do
        if on.nil?
          require_permission(permission)
        else
          require_permission(permission, on: send(on))
        end
      end
    end
  end

  private

  def configure_logging(&block)
    user_context = Timber::Contexts::User.new(
      id: current_user.id,
      email: current_user.email,
      name: current_user.display_name
    )
    Timber.with_context(user_context, &block)
  end

  def check_membership_status
    return if current_user.anonymous?

    call_service(CheckMembershipStatus,
                 user: current_user,
                 current: ->(*_) {},
                 expired: callback(:membership_expired),
                 no_history: callback(:no_membership_history))
  end

  callback(:membership_expired) do |membership|
    flash.now[:warning] = render_to_string('application/membership_expired_warning',
                                       locals: { membership: membership },
                                       layout: false)
  end

  callback(:no_membership_history) do
    flash.now[:warning] = render_to_string('application/no_membership_warning',
                                       layout: false)
  end

  def logged_in?
    !current_user.anonymous?
  end
  helper_method :logged_in?

  def current_user
    @current_user || User::Anonymous.new
  end

  def current_user=(user)
    session[:user_id] = user.id
    @current_user = user
  end

  alias service_context current_user
  alias service_logger logger

  def restore_current_user_from_session
    call_service(LoadCurrentUser, user_id: session[:user_id],
                 success: method(:current_user=))
  end

  def require_permission(permission, on: nil)
    call_service(Authorize, permission: permission,
                 on: on, not_authorized: method(:render_forbidden!))
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
        if current_user.anonymous?
          flash[:notice] = 'You must log in to access that page.'
          session[:post_authentication_url] = request.url if request.get?
          redirect_to new_session_path
        else
          render file: "#{Rails.root}/public/403", layout: false,
            status: :forbidden
        end
      end
      format.xml { head :forbidden }
      format.any { head :forbidden }
    end
  end

  def render_forbidden!
    render_forbidden
    halt!
  end

  def render_not_found
    respond_to do |format|
      format.html do
        render :file => "#{Rails.root}/public/404", :layout => false,
          :status => :not_found
      end
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end

  def render_not_found!
    render_not_found
    halt!
  end

  def halt!
    throw :halt
  end
end

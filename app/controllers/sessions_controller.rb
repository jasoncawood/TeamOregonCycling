class SessionsController < ApplicationController
  def create
    call_service(AuthenticateUser, email: session_params[:email],
                 password: session_params[:password],
                 success: method(:authenticated),
                 failed: method(:authentication_failed))
  end

  def destroy
    reset_session
    flash[:notice] = 'You have been signed out.'
    redirect_to root_path
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end

  def authenticated(user:)
    self.current_user = user
    redirect_to post_authentication_url
  end

  def post_authentication_url
    session.delete(:post_authentication_url) || root_path
  end

  def authentication_failed
    flash[:error] = 'The email and/or password you entered are not correct.'
    redirect_to new_session_path
  end
end

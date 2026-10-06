# Session-cookie authentication for the studio side of the site. Everything is
# closed by default; pages meant for visitors opt out with
# `allow_unauthenticated_access`.
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :current_user, :signed_in?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = session[:user_id] && User.find_by(id: session[:user_id])
  end

  def signed_in?
    current_user.present?
  end

  def require_authentication
    return if signed_in?

    session[:return_to] = request.fullpath if request.get? || request.head?
    redirect_to sign_in_path, alert: "Sign in to get into the studio."
  end

  def sign_in(user)
    reset_session
    session[:user_id] = user.id
    @current_user = user
  end

  def sign_out
    reset_session
    @current_user = nil
  end

  def after_sign_in_path
    session.delete(:return_to) || dashboard_path
  end
end

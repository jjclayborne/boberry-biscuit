# Session-cookie authentication for the studio. Everything is closed by default;
# pages meant for visitors opt out with `allow_unauthenticated_access`.
#
# The session carries the signed-in email and nothing else. It is checked back
# against the roster on every request, so removing someone from the list in
# credentials locks them out immediately, even mid-session.
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :current_account, :signed_in?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def current_account
    return @current_account if defined?(@current_account)

    @current_account = session[:account_email] && StudioAccount.find(session[:account_email])
  end

  def signed_in?
    current_account.present?
  end

  def require_authentication
    return if signed_in?

    session[:return_to] = request.fullpath if request.get? || request.head?
    redirect_to signin_path, alert: "Sign in to get into the studio."
  end

  def signin(account)
    reset_session
    session[:account_email] = account.email
    @current_account = account
  end

  def signout
    reset_session
    @current_account = nil
  end

  def after_sign_in_path
    session.delete(:return_to) || dashboard_path
  end
end

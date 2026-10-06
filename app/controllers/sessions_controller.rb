class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  layout "studio"

  def new
    redirect_to dashboard_path if signed_in?
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    if user&.authenticate(params[:password])
      destination = after_sign_in_path
      sign_in user
      redirect_to destination, notice: "Welcome back, #{user.name}."
    else
      @email = params[:email]
      flash.now[:alert] = "That email and password don't match a studio account."
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    sign_out
    redirect_to root_path, notice: "Signed out."
  end
end

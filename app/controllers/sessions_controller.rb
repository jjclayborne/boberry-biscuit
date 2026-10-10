class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  layout "studio"

  def new
    redirect_to dashboard_path if signed_in?
  end

  def create
    account = StudioAccount.authenticate(params[:email], params[:password])

    if account
      destination = after_sign_in_path
      signin account
      redirect_to destination, notice: "Welcome back."
    else
      @email = params[:email]
      flash.now[:alert] = "That email and password aren't on the studio's list."
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    signout
    redirect_to root_path, notice: "Signed out."
  end
end

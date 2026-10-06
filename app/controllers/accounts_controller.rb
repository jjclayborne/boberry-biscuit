# Self-service settings for whoever is signed in.
class AccountsController < ApplicationController
  layout "studio"

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(account_params)
      redirect_to account_path, notice: "Your account details were saved.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def account_params
    permitted = params.expect(user: [ :name, :email, :password, :password_confirmation ])
    # Leaving the password fields empty means "keep the one I have".
    permitted.delete(:password) if permitted[:password].blank?
    permitted.delete(:password_confirmation) if permitted[:password_confirmation].blank?
    permitted
  end
end

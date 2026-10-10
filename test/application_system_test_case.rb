require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1440, 1000 ]

  def sign_in_as(account = studio_account)
    credentials = credentials_for(account)

    visit signin_path
    fill_in "email", with: credentials[:email]
    fill_in "password", with: credentials[:password]
    click_on "[Sign in]"
  end
end

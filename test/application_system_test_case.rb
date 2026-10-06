require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1440, 1000 ]

  def sign_in_as(user, password: "letmein-studio")
    visit sign_in_path
    fill_in "email", with: user.email
    fill_in "password", with: password
    click_on "[Sign in]"
  end
end

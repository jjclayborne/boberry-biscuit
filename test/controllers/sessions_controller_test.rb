require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "the sign in page is open to everyone" do
    get sign_in_path
    assert_response :success
    assert_select "h2", "sign in"
  end

  test "signing in lands on the dashboard" do
    sign_in_as users(:nate)
    assert_redirected_to dashboard_path
  end

  test "the wrong password is rejected" do
    post sign_in_path, params: { email: users(:nate).email, password: "nope" }
    assert_response :unprocessable_content
    get dashboard_path
    assert_redirected_to sign_in_path
  end

  test "signing in returns to the page that asked for it" do
    get project_path(projects(:musgrave))
    assert_redirected_to sign_in_path

    sign_in_as users(:nate)
    assert_redirected_to project_path(projects(:musgrave))
  end

  test "signing out closes the studio" do
    sign_in_as users(:nate)
    delete sign_out_path
    assert_redirected_to root_path

    get dashboard_path
    assert_redirected_to sign_in_path
  end

  test "there is no way to sign up and no one to manage" do
    get "/sign_up"
    assert_response :not_found

    get "/users"
    assert_response :not_found
  end
end

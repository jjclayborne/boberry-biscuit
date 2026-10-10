require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "the sign in page is open to everyone" do
    get signin_path
    assert_response :success
    assert_select "h2", "sign in"
  end

  test "every account on the roster can sign in" do
    StudioAccount.roster.each do |account|
      post signin_path, params: credentials_for(account)
      assert_redirected_to dashboard_path

      get dashboard_path
      assert_response :success

      delete signout_path
    end
  end

  test "an email that is not on the roster is turned away" do
    post signin_path, params: { email: "stranger@example.test", password: "letmein-studio" }
    assert_response :unprocessable_content

    get dashboard_path
    assert_redirected_to signin_path
  end

  test "the wrong password is rejected" do
    post signin_path, params: { email: studio_account.email, password: "nope" }
    assert_response :unprocessable_content
  end

  test "signing in returns to the page that asked for it" do
    get project_path(projects(:musgrave))
    assert_redirected_to signin_path

    sign_in_as
    assert_redirected_to project_path(projects(:musgrave))
  end

  test "signing out closes the studio" do
    sign_in_as
    delete signout_path
    assert_redirected_to root_path

    get dashboard_path
    assert_redirected_to signin_path
  end

  test "a session whose email has left the roster is locked out at once" do
    sign_in_as

    with_roster [ { email: "someone-else@example.test", password: "x" } ] do
      get dashboard_path
      assert_redirected_to signin_path
    end
  end

  test "there is no way to sign up and no accounts to manage" do
    get "/sign_up"
    assert_response :not_found

    get "/users"
    assert_response :not_found

    get "/account"
    assert_response :not_found
  end
end

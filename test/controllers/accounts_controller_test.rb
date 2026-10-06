require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:nate) }

  test "anyone signed in can edit their own account" do
    get account_path
    assert_response :success
    assert_select "h1.studio-h1", "Your account"
  end

  test "saving a new name" do
    patch account_path, params: { user: { name: "Casey K.", email: users(:nate).email } }
    assert_redirected_to account_path
    assert_equal "Casey K.", users(:nate).reload.name
  end

  test "an empty password field leaves the password alone" do
    patch account_path, params: { user: { name: "Casey", email: users(:nate).email, password: "", password_confirmation: "" } }

    assert_redirected_to account_path
    assert users(:nate).reload.authenticate("letmein-studio")
  end

  test "a new password takes effect" do
    patch account_path, params: { user: {
      name: "Casey", email: users(:nate).email, password: "brand-new-pw", password_confirmation: "brand-new-pw"
    } }

    assert users(:nate).reload.authenticate("brand-new-pw")
  end

  test "a bad email is rejected" do
    patch account_path, params: { user: { name: "Casey", email: "not-an-email" } }
    assert_response :unprocessable_content
    assert_select ".studio-errors", /not a valid address/
  end
end

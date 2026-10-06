require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "visitors are sent to sign in" do
    get dashboard_path
    assert_redirected_to sign_in_path
  end

  test "the dashboard lists both sections and carries the create modals" do
    sign_in_as users(:nate)
    get dashboard_path

    assert_response :success
    assert_select "h2.studio-label", text: "selected commissions & sample work"
    assert_select "h2.studio-label", text: "artwork"
    assert_select "dialog#project-new"
    assert_select "dialog#work-new"
    assert_select "dialog#project-musgrave-edit"
    assert_select "a", text: "[Studio Keys]", count: 0
  end
end

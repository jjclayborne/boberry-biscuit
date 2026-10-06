require "test_helper"

class PortfolioControllerTest < ActionDispatch::IntegrationTest
  test "the portfolio is open to everyone" do
    get root_path
    assert_response :success
    assert_select "h2", text: "artist bio"
  end

  test "it shows published projects that have works, and nothing else" do
    get root_path

    assert_select "a[href=?]", "#/musgrave"
    assert_select "a[href=?]", "#/rites", false, "an unpublished project should stay off the site"
  end

  test "a published project with no works stays off the site" do
    projects(:rites).update!(published: true)
    get root_path
    assert_select "a[href=?]", "#/rites", false
  end

  test "each work hangs at its own proportions" do
    get root_path
    assert_select "[style*=?]", "aspect-ratio:1200 / 1500"
  end

  test "the studio link only shows once you are already in it" do
    get root_path
    assert_select "a[href=?]", sign_in_path, false, "the public has no door to be shown"

    sign_in_as users(:nate)
    get root_path
    assert_select "a[href=?]", dashboard_path
  end
end

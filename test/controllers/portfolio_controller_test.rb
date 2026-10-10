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

  test "a work on a project screen is the way into the viewer" do
    get root_path

    assert_select "button[data-action=?][aria-label=?]", "viewer#open", "See Slat Saw close up" do
      assert_select "img", 1
    end
    assert_select "dialog#work-viewer", 1, "one viewer serves every work on the page"
  end

  test "the viewer is handed the picture the work already shows" do
    get root_path

    plate = css_select(%q(button[aria-label="See Slat Saw close up"])).first
    assert_equal plate["data-viewer-src-param"], plate.at_css("img")["src"],
      "a second URL would mean a second download of the same picture"
  end

  test "the viewer is handed the words that go under the picture" do
    get root_path

    assert_select "button[data-viewer-name-param=?][data-viewer-fig-param=?][data-viewer-meta-param=?][data-viewer-note-param=?]",
      "Slat Saw", "1", "photography · 2025", "Cedar coming off the saw."
  end

  test "the footer carries a small key into the studio" do
    get root_path
    assert_select "a[href=?][aria-label=?]", signin_path, "sign in" do
      assert_select "svg", 1
    end
  end

  test "the key reads as the studio once you are already in it" do
    sign_in_as
    get root_path
    assert_select "a[href=?][aria-label=?]", signin_path, "the studio"
  end
end

require "application_system_test_case"

class PortfolioTest < ApplicationSystemTestCase
  test "a work on a project screen opens big, and the cursor magnifies it" do
    visit root_path
    click_on "Musgrave Pencil Company"

    find(%q(button[aria-label="See Slat Saw close up"])).click

    assert_selector "dialog#work-viewer[open]"
    within "dialog#work-viewer" do
      assert_text "fig. 1"
      assert_text "Slat Saw"
      assert_text "photography · 2025"
      assert_text "Cedar coming off the saw."
    end

    # The cursor on the picture puts the patch under it in the pane, and the
    # lens marks the patch.
    find("dialog#work-viewer .stage").hover
    assert_selector "dialog#work-viewer .pane.zooming"
    assert_selector "dialog#work-viewer .lens", visible: true
    assert_no_text "hover the picture to see it close up"

    # The cursor off the picture puts it back to the picture and the invitation.
    find("dialog#work-viewer .plate .name").hover
    assert_no_selector "dialog#work-viewer .pane.zooming"
    assert_no_selector "dialog#work-viewer .lens", visible: true
    assert_text "hover the picture to see it close up"
  end

  test "the viewer closes and leaves the project screen where it was" do
    visit root_path
    click_on "Musgrave Pencil Company"

    find(%q(button[aria-label="See Lacquer Line close up"])).click
    assert_selector "dialog#work-viewer[open]"

    within("dialog#work-viewer") { click_on "[close]" }

    assert_no_selector "dialog#work-viewer[open]"
    assert_text "A week on the factory floor."
  end
end

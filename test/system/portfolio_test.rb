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

  test "a video takes the whole stage, with no magnifier to offer" do
    work = projects(:musgrave).works.build(name: "Lacquer, Running", image_width: 1920, image_height: 1080)
    work.image.attach(sample_video)
    work.save!

    visit root_path
    click_on "Musgrave Pencil Company"
    find(%q(button[aria-label="Watch Lacquer, Running big"])).click

    assert_selector "dialog#work-viewer[open]"
    # The video is on the stage, the still is out of the way, and the pane --
    # which has nothing to magnify -- is gone rather than sitting there empty.
    assert_selector "dialog#work-viewer .stage.showing-video"
    assert_selector "dialog#work-viewer .stage video", visible: :all
    assert_no_selector "dialog#work-viewer .pane", visible: true

    # And the cursor on it does nothing, where on a photograph it would zoom.
    find("dialog#work-viewer .stage").hover
    assert_no_selector "dialog#work-viewer .lens", visible: true
  end

  test "closing the viewer puts a video down rather than leaving it running" do
    work = projects(:musgrave).works.build(name: "Lacquer, Running", image_width: 1920, image_height: 1080)
    work.image.attach(sample_video)
    work.save!

    visit root_path
    click_on "Musgrave Pencil Company"
    find(%q(button[aria-label="Watch Lacquer, Running big"])).click
    assert_selector "dialog#work-viewer[open]"

    within("dialog#work-viewer") { click_on "[close]" }

    assert_no_selector "dialog#work-viewer[open]"
    # No source left on the element: pausing alone would keep the file buffered
    # and the decoder warm behind the page. The dialog's close event arrives in
    # its own task, so this is a selector rather than a script -- it has to be
    # allowed to wait.
    assert_selector "dialog#work-viewer video:not([src])", visible: :all
  end

  test "a still work still gets its magnifier once a video is in the project" do
    work = projects(:musgrave).works.build(name: "Lacquer, Running", image_width: 1920, image_height: 1080)
    work.image.attach(sample_video)
    work.save!

    visit root_path
    click_on "Musgrave Pencil Company"
    find(%q(button[aria-label="See Slat Saw close up"])).click

    assert_no_selector "dialog#work-viewer .stage.showing-video"
    find("dialog#work-viewer .stage").hover
    assert_selector "dialog#work-viewer .pane.zooming"
    assert_selector "dialog#work-viewer .lens", visible: true
  end

  test "the viewer closes and leaves the project screen where it was" do
    visit root_path
    click_on "Musgrave Pencil Company"

    find(%q(button[aria-label="See Lacquer Line close up"])).click
    assert_selector "dialog#work-viewer[open]"

    page.execute_script("window.__closed = 0; document.querySelector('#work-viewer').addEventListener('close', () => window.__closed++)")
    within("dialog#work-viewer") { click_on "[close]" }

    assert_no_selector "dialog#work-viewer[open]"
    assert_text "A week on the factory floor."
  end
end

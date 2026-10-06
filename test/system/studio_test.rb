require "application_system_test_case"

class StudioTest < ApplicationSystemTestCase
  test "signing in, creating a project through the modal, and uploading a work" do
    sign_in_as users(:nate)
    assert_text "What's hanging"

    # The new-project modal opens from the dashboard and saves.
    click_on "[+ New project]"
    assert_selector "dialog#project-new[open]"

    within "dialog#project-new" do
      fill_in "project[name]", with: "Special Packaging"
      select "selected commissions & sample work", from: "project[section]"
      fill_in "project[kind]", with: "special packaging"
      fill_in "project[commission]", with: "La Mer Symphony Recording"
      fill_in "project[description]", with: "A sleeve for a recording of the sea."
      click_on "[Create project]"
    end

    assert_text "Special Packaging"
    assert_text "ready for works"
    assert_text "A work is the art itself"

    # A work needs its picture, and the upload modal carries it.
    click_on "[+ upload the first work]"
    assert_selector "dialog#work-new[open]"

    within "dialog#work-new" do
      attach_file "work[image]", file_fixture("plate.png").to_s
      fill_in "work[name]", with: "Tide Line"
      fill_in "work[medium]", with: "foil on board"
      click_on "[Add work]"
    end

    assert_text "Tide Line added to Special Packaging"
    assert_selector ".studio-grid .studio-plate img"

    # And once it holds a work it can go up on the portfolio.
    click_on "[Publish]"
    assert_text "on the portfolio"
  end

  test "a rejected project reopens its modal with the errors showing" do
    sign_in_as users(:nate)

    click_on "[+ New project]"
    within "dialog#project-new" do
      fill_in "project[name]", with: "Unclaimed"
      click_on "[Create project]"
    end

    assert_selector "dialog#project-new[open]"
    within "dialog#project-new" do
      assert_text "Commission is required for a commission"
      assert_field "project[name]", with: "Unclaimed"
    end
  end

  test "the cancel button closes a modal without saving" do
    sign_in_as users(:nate)

    click_on "[+ New project]"
    assert_selector "dialog#project-new[open]"

    within("dialog#project-new") { click_on "[cancel]" }
    assert_no_selector "dialog#project-new[open]"
  end

  test "yellow mode still works in the studio" do
    sign_in_as users(:nate)

    check "yellow?"
    assert_selector "body.studio[data-yellow]"
  end
end

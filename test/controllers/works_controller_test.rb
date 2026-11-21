require "test_helper"

class WorksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @work = works(:slat_saw)
    @project = projects(:musgrave)
    sign_in_as
  end

  test "the studio is closed to visitors" do
    delete signout_path
    post works_path, params: { work: { name: "Sneak", project_id: @project.id } }
    assert_redirected_to signin_path
  end

  test "uploading a work into a project" do
    assert_difference "Work.count" do
      post works_path, params: { work: {
        name: "Lacquer Dip", project_id: @project.id, medium: "photography", year: 2025,
        image_width: 1600, image_height: 1067, image: fixture_file_upload("plate.png", "image/png")
      } }
    end

    work = Work.order(:created_at).last
    assert_redirected_to project_path(@project)
    assert work.image.attached?
    assert_equal "1600 / 1067", work.aspect_ratio
  end

  test "uploading a video into a project" do
    assert_difference "Work.count" do
      post works_path, params: { work: {
        name: "Lacquer, Running", project_id: @project.id, medium: "video", year: 2026,
        image_width: 1920, image_height: 1080, image: fixture_file_upload("plate.mp4", "video/mp4")
      } }
    end

    work = Work.order(:created_at).last
    assert_redirected_to project_path(@project)
    assert work.video?
    assert_equal "1920 / 1080", work.aspect_ratio
  end

  test "uploading an animated GIF into a project" do
    assert_difference "Work.count" do
      post works_path, params: { work: {
        name: "Saw, Looping", project_id: @project.id,
        image_width: 2, image_height: 2, image: fixture_file_upload("plate.gif", "image/gif")
      } }
    end

    work = Work.order(:created_at).last
    assert work.moving?
    assert_not work.video?
  end

  test "a file that is neither picture nor video is rejected and reopens the upload modal" do
    assert_no_difference "Work.count" do
      post works_path, params: { work: {
        name: "Notes", project_id: @project.id,
        image: fixture_file_upload("notes.txt", "text/plain")
      } }
    end

    assert_response :unprocessable_content
    assert_select "dialog#work-new[data-studio-open=true]"
    assert_select ".studio-errors", /must be a picture or a video/
  end

  test "a rejected upload comes back with the form intact, file and all" do
    # The upload is attached to a record that never reached the database, so
    # anything in the form that reaches for its URL has to hold off.
    assert_no_difference "Work.count" do
      post works_path, params: { work: {
        name: "", project_id: @project.id, image: fixture_file_upload("plate.mp4", "video/mp4")
      } }
    end

    assert_response :unprocessable_content
    assert_select "dialog#work-new[data-studio-open=true]"
    assert_select ".studio-errors", /Name can't be blank/
  end

  test "what a file claims to be does not get a vote" do
    # Active Storage reads the bytes, so the allowlist is judged on what was
    # actually uploaded rather than on the name or the type the browser sent.
    post works_path, params: { work: {
      name: "Honest Video", project_id: @project.id,
      image: fixture_file_upload("plate.mp4", "image/png")
    } }

    assert_equal "video/mp4", Work.order(:created_at).last.content_type
  end

  test "a project screen renders a video work as a video" do
    post works_path, params: { work: {
      name: "Lacquer, Running", project_id: @project.id,
      image_width: 1920, image_height: 1080, image: fixture_file_upload("plate.mp4", "video/mp4")
    } }
    follow_redirect!

    assert_select ".studio-grid[data-controller=media]"
    assert_select ".studio-plate video[muted][loop][playsinline]"
  end

  test "a work without a picture is rejected and reopens the upload modal" do
    assert_no_difference "Work.count" do
      post works_path, params: { work: { name: "No Picture", project_id: @project.id } }
    end

    assert_response :unprocessable_content
    assert_select "dialog#work-new[data-studio-open=true]"
    assert_select ".studio-errors", /Image can't be blank/
  end

  test "a work with no project at all falls back to the dashboard" do
    post works_path, params: { work: { name: "Homeless" } }

    assert_response :unprocessable_content
    assert_select "dialog#work-new[data-studio-open=true]"
  end

  test "updating a work keeps the picture it already has" do
    patch work_path(@work), params: { work: { blurb: "Cedar, backlit." } }

    assert_redirected_to project_path(@project)
    assert_equal "Cedar, backlit.", @work.reload.blurb
    assert @work.image.attached?
  end

  test "a rejected edit that swapped the file comes back in one piece" do
    # The work is saved but the picture it now holds is not, so the plate in
    # the grid behind the modal has a file with no address yet.
    patch work_path(@work), params: { work: {
      name: "", image: fixture_file_upload("plate.mp4", "video/mp4")
    } }

    assert_response :unprocessable_content
    assert_select "dialog#work-#{@work.id}-edit[data-studio-open=true]"
    assert_select ".studio-errors", /Name can't be blank/
  end

  test "a rejected edit reopens that work's modal" do
    patch work_path(@work), params: { work: { name: "" } }

    assert_response :unprocessable_content
    assert_select "dialog#work-#{@work.id}-edit[data-studio-open=true]"
  end

  test "deleting a work" do
    assert_difference "Work.count", -1 do
      delete work_path(@work)
    end
    assert_redirected_to project_path(@project)
  end
end

require "test_helper"

class WorksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @work = works(:slat_saw)
    @project = projects(:musgrave)
    sign_in_as users(:nate)
  end

  test "the studio is closed to visitors" do
    delete sign_out_path
    post works_path, params: { work: { name: "Sneak", project_id: @project.id } }
    assert_redirected_to sign_in_path
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

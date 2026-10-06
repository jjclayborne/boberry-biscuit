require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:musgrave)
    sign_in_as users(:nate)
  end

  test "the studio is closed to visitors" do
    delete sign_out_path
    get project_path(@project)
    assert_redirected_to sign_in_path
  end

  test "index sends you to the dashboard" do
    get projects_path
    assert_redirected_to dashboard_path
  end

  test "show lists the works and their modals" do
    get project_path(@project)

    assert_response :success
    assert_select "h1.studio-h1", @project.display_name
    assert_select ".studio-grid .studio-plate", @project.works.count
    assert_select "dialog#project-details"
    assert_select "dialog#work-new"
    assert_select "dialog#work-#{works(:slat_saw).id}-edit"
  end

  test "creating a project" do
    assert_difference "Project.count" do
      post projects_path, params: { project: {
        name: "Special Packaging", section: "commission", commission: "La Mer", kind: "packaging"
      } }
    end

    assert_redirected_to project_path(Project.find_by!(slug: "special-packaging"))
  end

  test "a rejected project comes back on the dashboard with its modal open" do
    assert_no_difference "Project.count" do
      post projects_path, params: { from: "dashboard", project: { name: "Unclaimed", section: "commission" } }
    end

    assert_response :unprocessable_content
    assert_select "dialog#project-new[data-studio-open=true]"
    assert_select ".studio-errors", /is required for a commission/
  end

  test "updating a project" do
    patch project_path(@project), params: { project: { description: "Rewritten." } }
    assert_redirected_to project_path(@project)
    assert_equal "Rewritten.", @project.reload.description
  end

  test "publishing from the dashboard" do
    project = projects(:rites)
    work = project.works.build(name: "Plate", image_width: 10, image_height: 10)
    work.image.attach(sample_image)
    work.save!

    patch project_path(project), params: { from: "dashboard", project: { published: true } }
    assert project.reload.published?
  end

  test "a rejected edit from the dashboard reopens that project's modal" do
    patch project_path(@project), params: { from: "dashboard", project: { name: "" } }

    assert_response :unprocessable_content
    assert_select "dialog#project-musgrave-edit[data-studio-open=true]"
  end

  test "a rejected edit from the project page reopens the details modal" do
    patch project_path(@project), params: { project: { name: "" } }

    assert_response :unprocessable_content
    assert_select "dialog#project-details[data-studio-open=true]"
  end

  test "deleting a project" do
    assert_difference "Project.count", -1 do
      delete project_path(@project)
    end
    assert_redirected_to dashboard_path
  end
end

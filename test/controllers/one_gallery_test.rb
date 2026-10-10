require "test_helper"

# Every account on the roster opens the SAME gallery. Nothing in this app is
# scoped to whoever signed in, and these tests are here to keep it that way.
class OneGalleryTest < ActionDispatch::IntegrationTest
  test "the roster has more than one account to compare" do
    assert_operator StudioAccount.roster.size, :>=, 2
  end

  test "a project made by one account is there for the next one" do
    sign_in_as studio_account(:first)
    post projects_path, params: { project: {
      name: "Shared Section", section: "artwork", description: "Made by the first account."
    } }
    project = Project.find_by!(slug: "shared-section")
    delete signout_path

    sign_in_as studio_account(:second)
    get dashboard_path
    assert_response :success
    assert_select "a", text: "Shared Section"

    get project_path(project)
    assert_response :success
    assert_select "h1.studio-h1", "Shared Section"
  end

  test "a work uploaded by one account is there for the next one" do
    sign_in_as studio_account(:second)
    post works_path, params: { work: {
      name: "Shared Plate", project_id: projects(:musgrave).id,
      image: fixture_file_upload("plate.png", "image/png")
    } }
    assert_redirected_to project_path(projects(:musgrave))
    delete signout_path

    sign_in_as studio_account(:first)
    get project_path(projects(:musgrave))
    assert_select ".studio-grid .studio-plate", text: /Shared Plate/
  end

  test "both accounts see the identical dashboard" do
    sign_in_as studio_account(:first)
    get dashboard_path
    first_view = css_select(".studio-row .title").map(&:text)
    delete signout_path

    sign_in_as studio_account(:second)
    get dashboard_path
    assert_equal first_view, css_select(".studio-row .title").map(&:text)
  end

  test "an edit by one account is visible to the other" do
    sign_in_as studio_account(:first)
    patch project_path(projects(:musgrave)), params: { project: { description: "Rewritten by the first." } }
    delete signout_path

    sign_in_as studio_account(:second)
    get project_path(projects(:musgrave))
    assert_select ".studio-prose", "Rewritten by the first."
  end

  test "nothing in the schema is scoped to an account" do
    account_columns = ActiveRecord::Base.connection.tables.flat_map do |table|
      ActiveRecord::Base.connection.columns(table).map { |column| "#{table}.#{column.name}" }
    end.grep(/user_id|account_id|owner_id/)

    assert_empty account_columns, "a per-account column would let a second gallery exist"
  end
end

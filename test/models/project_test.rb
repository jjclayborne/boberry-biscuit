require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "slug comes from the name when left blank" do
    project = Project.create!(name: "Poster Design & Letterpress", section: "artwork")
    assert_equal "poster-design-letterpress", project.slug
  end

  test "a commission has to name who it was made for" do
    project = Project.new(name: "Unclaimed", section: "commission")
    assert_not project.valid?
    assert_includes project.errors[:commission], "is required for a commission"
  end

  test "artwork needs no client" do
    assert Project.new(name: "Welcome Fabric", section: "artwork").valid?
  end

  test "new projects land at the end of their own section" do
    last = Project.commissions.maximum(:position)
    project = Project.create!(name: "Next", section: "commission", commission: "Someone")
    assert_equal last + 1, project.position
  end

  test "listing label reads as medium for client" do
    assert_equal "photography for Musgrave Pencil Company", projects(:musgrave).listing_label
    assert_equal "Rites of Passage", projects(:rites).listing_label
  end

  test "a project is only publishable once it holds a work" do
    assert projects(:musgrave).publishable?
    assert_not projects(:rites).publishable?
  end

  test "deleting a project takes its works with it" do
    assert_difference "Work.count", -projects(:musgrave).works.count do
      projects(:musgrave).destroy!
    end
  end

  test "identity falls back to stored values while an edit is unsaved" do
    project = projects(:musgrave)
    project.slug = "renamed"
    project.name = ""

    assert_equal "musgrave", project.to_param
    assert_equal "Photography", project.display_name
  end
end

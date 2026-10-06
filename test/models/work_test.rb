require "test_helper"

class WorkTest < ActiveSupport::TestCase
  test "a work cannot be saved without a picture" do
    work = Work.new(name: "Nothing To See", project: projects(:musgrave))
    assert_not work.valid?
    assert_includes work.errors[:image], "can't be blank"
  end

  test "the picture has to be an image" do
    work = Work.new(name: "Readme", project: projects(:musgrave))
    work.image.attach(io: StringIO.new("not an image"), filename: "notes.txt", content_type: "text/plain")
    assert_not work.valid?
    assert_includes work.errors[:image], "must be an image file"
  end

  test "aspect ratio uses the measured dimensions" do
    assert_equal "1200 / 1500", works(:slat_saw).aspect_ratio
  end

  test "aspect ratio falls back to a portrait crop when nothing is known" do
    work = works(:slat_saw)
    work.update_columns(image_width: nil, image_height: nil)
    assert_equal Work::DEFAULT_ASPECT_RATIO, work.reload.aspect_ratio
  end

  test "new works land at the end of their project" do
    project = projects(:musgrave)
    work = project.works.build(name: "Third", image_width: 100, image_height: 100)
    work.image.attach(sample_image)
    work.save!
    assert_equal 3, work.position
  end
end

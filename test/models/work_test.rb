require "test_helper"

class WorkTest < ActiveSupport::TestCase
  test "a work cannot be saved without a picture" do
    work = Work.new(name: "Nothing To See", project: projects(:musgrave))
    assert_not work.valid?
    assert_includes work.errors[:image], "can't be blank"
  end

  test "the picture has to be something a browser can hang" do
    work = Work.new(name: "Readme", project: projects(:musgrave))
    work.image.attach(io: StringIO.new("not an image"), filename: "notes.txt", content_type: "text/plain")
    assert_not work.valid?
    assert_includes work.errors[:image].first, "must be a picture or a video"
  end

  test "a PDF is turned away even though it is a document full of pictures" do
    work = Work.new(name: "Catalogue", project: projects(:musgrave))
    work.image.attach(io: StringIO.new("%PDF-1.4"), filename: "catalogue.pdf", content_type: "application/pdf")
    assert_not work.valid?
    assert_includes work.errors[:image].first, "must be a picture or a video"
  end

  test "every hangable type is accepted" do
    Work::MEDIA_TYPES.each do |type|
      work = projects(:musgrave).works.build(name: "A #{type}")
      work.image.attach(io: StringIO.new("pretend bytes"), filename: "work", content_type: type)
      assert work.valid?, "#{type} should be hangable: #{work.errors[:image].inspect}"
    end
  end

  test "a file over the ceiling is turned away rather than left to die in a proxy" do
    # Rewriting the size the upload reports is enough: the validation reads it
    # off the blob, and pushing 50MB through the suite to prove that is not
    # worth the seconds.
    assert_not oversized_by(1).valid?
    assert_includes oversized_by(1).tap(&:valid?).errors[:image].first, "the limit is"
  end

  test "a file right on the ceiling is let through" do
    assert oversized_by(0).valid?
  end

  test "a rule written today cannot reach back and strand a work already hanging" do
    # The allowlist is narrower than the "any image" it replaced, and Nate's
    # gallery predates it. Whatever is already stored has to stay editable.
    work = sample_work(sample_image)
    work.image.blob.update_columns(content_type: "image/tiff", byte_size: Work::MAX_UPLOAD * 2)

    work.reload
    assert work.valid?, work.errors.full_messages.inspect
    assert work.update(name: "Retitled")
  end

  test "but the next upload onto that work is judged by the list" do
    work = sample_work(sample_image)
    work.image.blob.update_columns(content_type: "image/tiff")

    work.reload.image.attach(io: StringIO.new("still not hangable"), filename: "scan.tiff", content_type: "image/tiff")
    assert_not work.valid?
    assert_includes work.errors[:image].first, "must be a picture or a video"
  end

  test "a video knows it is one, and so does a GIF" do
    assert sample_work(sample_video).video?
    assert_not sample_work(sample_gif).video?
    assert_not sample_work(sample_image).video?
  end

  test "a GIF and a video move; a photograph holds still" do
    assert sample_work(sample_video).moving?
    assert sample_work(sample_gif).moving?
    assert sample_work(sample_image).still?
  end

  test "a moving work is served as uploaded, because a resize would flatten it" do
    gif = sample_work(sample_gif)
    video = sample_work(sample_video)

    # The attachment itself, not a variant of it.
    assert_equal gif.image, gif.thumbnail
    assert_equal gif.image, gif.display_image
    assert_equal video.image, video.display_image
  end

  test "a still is still resized where the machine can do it" do
    still = sample_work(sample_image)

    if Work.resizable?
      assert_kind_of ActiveStorage::VariantWithRecord, still.thumbnail
    else
      assert_equal still.image, still.thumbnail
    end
  end

  test "aspect ratio uses the measured dimensions" do
    assert_equal "1200 / 1500", works(:slat_saw).aspect_ratio
  end

  test "aspect ratio falls back to a portrait crop when nothing is known" do
    work = works(:slat_saw)
    work.update_columns(image_width: nil, image_height: nil)
    assert_equal Work::DEFAULT_ASPECT_RATIO, work.reload.aspect_ratio
  end

  test "a video hangs at the proportions the upload form measured in the browser" do
    # There is no ffprobe here, so Active Storage records no dimensions of its
    # own -- what the browser measured is the only thing keeping this video off
    # the default portrait crop.
    work = projects(:musgrave).works.build(name: "Lacquer, Running", image_width: 1920, image_height: 1080)
    work.image.attach(sample_video)
    work.save!

    assert_empty work.image.metadata.slice("width", "height")
    assert_equal "1920 / 1080", work.aspect_ratio
  end

  test "new works land at the end of their project" do
    project = projects(:musgrave)
    work = project.works.build(name: "Third", image_width: 100, image_height: 100)
    work.image.attach(sample_image)
    work.save!
    assert_equal 3, work.position
  end

  private

  def oversized_by(extra)
    work = projects(:musgrave).works.build(name: "The Director's Cut")
    work.image.attach(sample_video)
    work.image.blob.byte_size = Work::MAX_UPLOAD + extra
    work
  end

  def sample_work(attachment)
    work = projects(:musgrave).works.build(name: "Sample", image_width: 100, image_height: 100)
    work.image.attach(attachment)
    work.tap(&:save!)
  end
end

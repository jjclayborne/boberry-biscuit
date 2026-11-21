class Work < ApplicationRecord
  # A work is the art itself, so it always carries its picture -- there is
  # nothing to show without one. A picture is allowed to move: an animated GIF
  # or a video hangs in the same frame, at the same proportions, as a still.
  DEFAULT_ASPECT_RATIO = "4 / 5".freeze

  # What may be hung. Everything here is something a browser can show without
  # a plugin, which is the whole bar -- the portfolio has no player of its own.
  IMAGE_TYPES = %w[ image/jpeg image/png image/webp image/avif image/gif ].freeze
  VIDEO_TYPES = %w[ video/mp4 video/quicktime ].freeze
  MEDIA_TYPES = (IMAGE_TYPES + VIDEO_TYPES).freeze

  # A video runs an order of magnitude larger than a photograph, so the ceiling
  # is high -- but there is one, because an upload that dies halfway through a
  # proxy is a worse experience than one that is turned away at the form.
  MAX_UPLOAD = 50.megabytes

  belongs_to :project, inverse_of: :works

  has_one_attached :image

  normalizes :name, :blurb, :medium, with: ->(value) { value.to_s.strip.presence }

  before_validation :assign_position, on: :create

  validates :name, presence: true, length: { maximum: 120 }
  validates :blurb, length: { maximum: 280 }
  validates :image, presence: true
  validates :year, numericality: { only_integer: true, greater_than: 1900, less_than_or_equal_to: ->(_) { Date.current.year + 1 } }, allow_nil: true
  validate :image_must_be_hangable
  validate :image_must_fit

  scope :ordered, -> { order(:position, :created_at) }

  delegate :section, to: :project, allow_nil: true

  def content_type
    image.content_type if image.attached?
  end

  def video?
    VIDEO_TYPES.include?(content_type)
  end

  # A GIF and a video both lose the only thing that makes them worth hanging if
  # something flattens them to a single frame -- so neither gets resized, and
  # neither goes anywhere that crossfades.
  def moving?
    video? || content_type == "image/gif"
  end

  def still?
    !moving?
  end

  # An attachment that hasn't been saved has no address to serve from, and
  # asking one for a URL raises. A rejected form is exactly where that happens:
  # the upload is attached to a record that never made it to the database, so
  # the form has the file in hand and nowhere to point at it.
  def image_stored?
    image.attached? && image.attachment.persisted?
  end

  # The portfolio hangs each work at its own proportions. Prefer whatever Active
  # Storage analysed, fall back to what the upload form measured in the browser,
  # and settle for a portrait crop when neither is known. Video analysis wants
  # ffprobe, which is not installed, so for a video the browser's measurement is
  # in practice the only source -- see image_field_controller.js.
  def aspect_ratio
    width = image_metadata["width"].presence || image_width
    height = image_metadata["height"].presence || image_height
    return DEFAULT_ASPECT_RATIO unless width.to_i.positive? && height.to_i.positive?

    "#{width} / #{height}"
  end

  # Resized copies need libvips or ImageMagick on the machine; where neither is
  # installed we serve the file as uploaded rather than blowing up the page.
  def thumbnail
    sized_image(600)
  end

  def display_image
    sized_image(2000)
  end

  def caption
    [ name, year ].compact.join(", ")
  end

  def self.resizable?
    return @resizable unless @resizable.nil?

    @resizable =
      begin
        ActiveStorage.variant_processor == :vips ? require("vips") : require("mini_magick")
        true
      rescue LoadError
        false
      end
  end

  private

  def sized_image(limit)
    return unless image.attached?
    return image if moving?
    return image unless image.variable? && self.class.resizable?

    image.variant(resize_to_limit: [ limit, limit ])
  end

  def image_metadata
    image.attached? ? image.metadata || {} : {}
  end

  # Both of these judge what is being uploaded now, not what is already
  # hanging. A rule written today should not be able to reach back and make an
  # existing work unsaveable -- that would turn a narrowed list of formats into
  # a work nobody can so much as retitle.
  def uploading?
    image.attached? && image.attachment.new_record?
  end

  def image_must_be_hangable
    return unless uploading?
    return if MEDIA_TYPES.include?(image.content_type)

    errors.add(:image, "must be a picture or a video — JPEG, PNG, WebP, AVIF, GIF, MP4 or MOV")
  end

  def image_must_fit
    return unless uploading? && image.byte_size.to_i > MAX_UPLOAD

    errors.add(:image, "is #{number_to_human_size(image.byte_size)} — the limit is #{number_to_human_size(MAX_UPLOAD)}")
  end

  def number_to_human_size(bytes)
    ActiveSupport::NumberHelper.number_to_human_size(bytes)
  end

  def assign_position
    self.position = (project&.works&.maximum(:position) || 0) + 1 if position.to_i.zero?
  end
end

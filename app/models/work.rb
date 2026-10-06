class Work < ApplicationRecord
  # A work is the art itself, so it always carries its picture -- there is
  # nothing to show without one.
  DEFAULT_ASPECT_RATIO = "4 / 5".freeze

  belongs_to :project, inverse_of: :works

  has_one_attached :image

  normalizes :name, :blurb, :medium, with: ->(value) { value.to_s.strip.presence }

  before_validation :assign_position, on: :create

  validates :name, presence: true, length: { maximum: 120 }
  validates :blurb, length: { maximum: 280 }
  validates :image, presence: true
  validates :year, numericality: { only_integer: true, greater_than: 1900, less_than_or_equal_to: ->(_) { Date.current.year + 1 } }, allow_nil: true
  validate :image_must_be_an_image

  scope :ordered, -> { order(:position, :created_at) }

  delegate :section, to: :project, allow_nil: true

  # The portfolio hangs each work at its own proportions. Prefer whatever Active
  # Storage analysed, fall back to what the upload form measured in the browser,
  # and settle for a portrait crop when neither is known.
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
    return image unless image.variable? && self.class.resizable?

    image.variant(resize_to_limit: [ limit, limit ])
  end

  def image_metadata
    image.attached? ? image.metadata || {} : {}
  end

  def image_must_be_an_image
    return unless image.attached?

    errors.add(:image, "must be an image file") unless image.content_type&.start_with?("image/")
  end

  def assign_position
    self.position = (project&.works&.maximum(:position) || 0) + 1 if position.to_i.zero?
  end
end

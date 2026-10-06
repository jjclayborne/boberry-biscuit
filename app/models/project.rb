class Project < ApplicationRecord
  # A project groups works the way a section of a gallery does: one theme or
  # throughline. Commissions were made for someone (`commission` holds the
  # client); artwork is the artist's own.
  SECTIONS = %w[ commission artwork ].freeze

  has_many :works, -> { ordered }, dependent: :destroy, inverse_of: :project

  normalizes :name, :kind, :commission, with: ->(value) { value.to_s.strip.presence }
  normalizes :slug, with: ->(value) { value.to_s.parameterize.presence }

  before_validation :assign_slug
  before_validation :assign_position, on: :create

  validates :name, presence: true, length: { maximum: 120 }
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9\-]+\z/, message: "may only contain lowercase letters, numbers and dashes" }
  validates :section, inclusion: { in: SECTIONS }
  validates :commission, presence: { message: "is required for a commission" }, if: :commission_section?
  validates :year, numericality: { only_integer: true, greater_than: 1900, less_than_or_equal_to: ->(_) { Date.current.year + 1 } }, allow_nil: true

  scope :ordered, -> { order(:position, :created_at) }
  scope :published, -> { where(published: true) }
  scope :commissions, -> { where(section: "commission") }
  scope :artwork, -> { where(section: "artwork") }

  def commission_section?
    section == "commission"
  end

  # A rejected edit still holds whatever was typed into the form, so anything
  # identifying the project -- routes, dom ids, page headings -- has to reach
  # for the values actually stored.
  def to_param
    slug_in_database || slug
  end

  def display_name
    name.presence || name_in_database
  end

  # What the portfolio lists under "selected commissions": "photography for
  # Musgrave Pencil Company". Artwork just goes by its own name.
  def listing_label
    return name unless commission_section?

    [ kind.presence || name.downcase, commission ].compact.join(" for ")
  end

  def cover
    works.detect { |work| work.image.attached? } || works.first
  end

  def publishable?
    works.any?
  end

  private

  def assign_slug
    self.slug = name.to_s.parameterize if slug.blank?
  end

  def assign_position
    self.position = (self.class.where(section: section).maximum(:position) || 0) + 1 if position.to_i.zero?
  end
end

class PortfolioController < ApplicationController
  allow_unauthenticated_access

  BIO = "Nate Kammerer is an artist and designer based in Nashville, Tennessee, " \
    "currently studying Design Communications and Photography at the Watkins College of " \
    "Art at Belmont University.".freeze

  def show
    @projects = Project.published.ordered.includes(works: { image_attachment: :blob }).select(&:publishable?)
    @commissions = @projects.select(&:commission_section?)
    @artwork = @projects.reject(&:commission_section?)
    # The featured window crossfades one work into the next, so it wants
    # things that hold still -- four videos stacked and dissolving into each
    # other is four videos decoding at once, and a mess to look at.
    @heroes = @projects.flat_map(&:works).select { |work| work.image.attached? && work.still? }.sample(4)
    @bio = BIO
    @last_updated = Work.maximum(:updated_at) || Project.maximum(:updated_at)
  end
end

module PortfolioHelper
  # The works a project link flashes up in the featured window while hovered.
  # Stills only, for the same reason the featured window itself takes stills:
  # the peek dissolves between two <img> layers, and a video has no place in
  # a crossfade that lasts as long as a hover.
  def peek_works(project)
    project.works.select { |work| work.image.attached? && work.still? }.map do |work|
      { src: url_for(work.display_image), caption: "#{work.caption} — #{project.name}" }
    end.to_json
  end
end

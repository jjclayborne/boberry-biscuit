module PortfolioHelper
  # The works a project link flashes up in the featured window while hovered.
  def peek_works(project)
    project.works.select { |work| work.image.attached? }.map do |work|
      { src: url_for(work.display_image), caption: "#{work.caption} — #{project.name}" }
    end.to_json
  end
end

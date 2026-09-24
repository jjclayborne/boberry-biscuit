class PortfolioController < ApplicationController
  IMAGE_RATIOS = ["4/5", "3/2", "1/1", "4/5", "3/2"].freeze

  PROJECT_BODY = "Ferovitatur antem quia voluptur rest omnis dias dunt et et voluptatione et " \
    "utatend iciuscimodit inctaec ulluptiorrum dit iscid ut ea diciis vitatisquam rem. Ihit odis " \
    "aut audanitatur, sum si nihitiis aut fugit, estius adiscitiur, sequi nienissunt fuga.".freeze

  HEROES = [
    { label: "highlighted image 1", caption: "Hatch Show Print, 2025" },
    { label: "highlighted image 2", caption: "Rites of Passage, 2026" },
    { label: "highlighted image 3", caption: "Musgrave Pencil Co., 2025" },
    { label: "highlighted image 4", caption: "Welcome Fabric, 2026" }
  ].freeze

  PROJECTS = [
    { id: "musgrave", kind: "photography", title: "Photography", client: "Musgrave Pencil Company", section: "selected commissions & sample work" },
    { id: "hatch", kind: "poster design and letterpress printing", title: "Poster Design & Letterpress", client: "Hatch Show Print", section: "selected commissions & sample work" },
    { id: "millerknoll", kind: "layout", title: "Layout", client: "MillerKnoll", section: "selected commissions & sample work" },
    { id: "watkins", kind: "exhibition design", title: "Exhibition Design", client: "Watkins Art Gallery", section: "selected commissions & sample work" },
    { id: "peglegporker", kind: "brand identity and menu design", title: "Brand Identity & Menus", client: "Peg Leg Porker", section: "selected commissions & sample work" },
    { id: "lamer", kind: "special packaging", title: "Special Packaging", client: "La Mer Symphony Recording", section: "selected commissions & sample work" },
    { id: "rites", art: true, title: "Rites of Passage", client: "Rites of Passage", section: "artwork" },
    { id: "welcome", art: true, title: "Welcome Fabric", client: "Welcome Fabric", section: "artwork" }
  ].freeze

  def show
    @heroes = HEROES
    @projects = PROJECTS.map do |project|
      project.merge(
        client_lower: project[:client].downcase,
        body: PROJECT_BODY,
        images: IMAGE_RATIOS.each_with_index.map { |ratio, i| { ratio: ratio, n: i + 1, label: "image here — #{project[:id]} #{i + 1}" } }
      )
    end
    @commissions = @projects.reject { |p| p[:art] }
    @artwork = @projects.select { |p| p[:art] }
  end
end

# Seeds the studio's one account and the projects the portfolio was first
# designed around. Safe to run repeatedly.
require_relative "seeds/placeholder_image"

owner = User.first || User.new
owner.update!(
  name: "Nate Kammerer",
  email: "nate@boberrybiscuit.test",
  password: ENV.fetch("SEED_PASSWORD", "letmein-studio"),
  password_confirmation: ENV.fetch("SEED_PASSWORD", "letmein-studio")
)

PROJECT_SEEDS = [
  { slug: "musgrave", name: "Photography", kind: "photography", commission: "Musgrave Pencil Company", section: "commission", year: 2025,
    description: "A week in the last pencil factory in Shelbyville, shot on the floor between the slat saws and the lacquer line." },
  { slug: "hatch", name: "Poster Design & Letterpress", kind: "poster design and letterpress printing", commission: "Hatch Show Print", section: "commission", year: 2025,
    description: "Wood type pulled by hand, then redrawn so the show posters read from across the street." },
  { slug: "millerknoll", name: "Layout", kind: "layout", commission: "MillerKnoll", section: "commission", year: 2026,
    description: "A catalogue grid loose enough for the furniture to breathe and tight enough to price." },
  { slug: "watkins", name: "Exhibition Design", kind: "exhibition design", commission: "Watkins Art Gallery", section: "commission", year: 2026,
    description: "Wall sequence, labels and lighting for the spring thesis show." },
  { slug: "peglegporker", name: "Brand Identity & Menus", kind: "brand identity and menu design", commission: "Peg Leg Porker", section: "commission", year: 2025,
    description: "A mark that holds up on a smoker, a sign, and a grease-spotted menu." },
  { slug: "lamer", name: "Special Packaging", kind: "special packaging", commission: "La Mer Symphony Recording", section: "commission", year: 2026,
    description: "A sleeve for a recording of the sea: three folds, one tide line." },
  { slug: "rites", name: "Rites of Passage", section: "artwork", year: 2026,
    description: "Photographs of the small ceremonies nobody announces." },
  { slug: "welcome", name: "Welcome Fabric", section: "artwork", year: 2026,
    description: "Dyed and printed cloth hung the way a doormat is laid down." }
].freeze

SIZES = [ [ 1200, 1500 ], [ 1500, 1000 ], [ 1200, 1200 ], [ 1000, 1250 ], [ 1600, 1067 ] ].freeze

PROJECT_SEEDS.each_with_index do |attributes, index|
  project = Project.find_or_initialize_by(slug: attributes[:slug])
  project.assign_attributes(attributes.merge(position: index + 1, published: true))
  project.save!

  next if project.works.any?

  SIZES.each_with_index do |(width, height), figure|
    work = project.works.build(
      name: "#{project.name} (no. #{figure + 1})",
      medium: project.kind.presence || "mixed media",
      year: project.year,
      position: figure + 1,
      image_width: width,
      image_height: height
    )
    work.image.attach(
      io: StringIO.new(PlaceholderImage.png(width / 4, height / 4, seed: index * 5 + figure)),
      filename: "#{project.slug}-#{figure + 1}.png",
      content_type: "image/png"
    )
    work.save!
  end
end

puts "Seeded #{Project.count} projects and #{Work.count} works."
puts "Sign in at /sign_in as #{owner.email}"

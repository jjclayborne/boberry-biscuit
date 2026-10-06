require "zlib"
require "stringio"

# Seed data needs pictures, because a work can't exist without one. Rather than
# check binary fixtures into the repo, draw them: a cream plate with the same
# diagonal hatch the portfolio uses for empty frames.
module PlaceholderImage
  PAPER = [ 0xef, 0xea, 0xe0 ].freeze
  HATCH = [ 0xe8, 0xe2, 0xd5 ].freeze
  INK   = [ 0x1c, 0x1a, 0x17 ].freeze

  def self.png(width, height, seed: 0)
    scanlines = (0...height).map do |y|
      row = (0...width).map { |x| pixel(x, y, width, height, seed) }
      ([ 0 ] + row.flatten).pack("C*")
    end

    chunks = [
      chunk("IHDR", [ width, height, 8, 2, 0, 0, 0 ].pack("NNC5")),
      chunk("IDAT", Zlib::Deflate.deflate(scanlines.join)),
      chunk("IEND", "")
    ]

    "\x89PNG\r\n\x1a\n".b + chunks.join
  end

  def self.pixel(x, y, width, height, seed)
    border = 6
    return INK if x < border || y < border || x >= width - border || y >= height - border

    # A band through the middle keeps each seeded plate distinguishable.
    band = ((seed * 37) % 5) + 1
    return INK if ((y * band) % height).between?(height / 2, height / 2 + 2)

    (((x + y + seed * 13) / 7) % 2).zero? ? HATCH : PAPER
  end
  private_class_method :pixel

  def self.chunk(type, data)
    body = type.b + data.b
    [ data.bytesize ].pack("N") + body + [ Zlib.crc32(body) ].pack("N")
  end
  private_class_method :chunk
end

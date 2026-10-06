class AddImageDimensionsToWorks < ActiveRecord::Migration[8.1]
  def change
    # The portfolio hangs every work at its own proportions. Active Storage can
    # only report those once libvips or ImageMagick is installed, so the upload
    # form measures the picture in the browser and sends the numbers along.
    change_table :works, bulk: true do |t|
      t.integer :image_width
      t.integer :image_height
    end
  end
end

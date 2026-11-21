import { Controller } from "@hotwired/stimulus"

// Shows the picture someone just picked, so they can tell before saving that
// they grabbed the right file -- and measures it, because the proportions it
// records are what the portfolio hangs the work at.
//
// For a video that measurement is not a nicety: Active Storage reads a video's
// dimensions with ffprobe, which isn't installed, so what the browser reports
// here is the only thing standing between the work and the default portrait
// crop.
export default class extends Controller {
  static targets = ["input", "preview", "image", "video", "width", "height"]

  preview() {
    const file = this.inputTarget.files?.[0]
    if (!file) return

    this.revoke()
    this.url = URL.createObjectURL(file)

    const moving = file.type.startsWith("video/")
    const showing = moving ? this.videoTarget : this.imageTarget
    const hiding = moving ? this.imageTarget : this.videoTarget

    hiding.hidden = true
    hiding.removeAttribute("src")
    if (hiding.load) hiding.load() // a video goes on buffering until it's told not to
    showing.hidden = false
    showing.src = this.url
    this.previewTarget.style.display = ""

    // Pass the real proportions along so the portfolio can hang the work at them.
    if (moving) {
      showing.onloadedmetadata = () => this.recordSize(showing.videoWidth, showing.videoHeight)
      showing.load()
    } else {
      showing.onload = () => this.recordSize(showing.naturalWidth, showing.naturalHeight)
    }
  }

  recordSize(width, height) {
    if (!width || !height) return

    if (this.hasWidthTarget) this.widthTarget.value = width
    if (this.hasHeightTarget) this.heightTarget.value = height
    this.previewTarget.querySelector(".frame").style.aspectRatio = `${width} / ${height}`
  }

  disconnect() {
    this.revoke()
  }

  revoke() {
    if (this.url) URL.revokeObjectURL(this.url)
    this.url = null
  }
}

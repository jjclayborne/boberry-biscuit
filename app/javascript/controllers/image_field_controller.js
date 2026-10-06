import { Controller } from "@hotwired/stimulus"

// Shows the picture someone just picked, so they can tell before saving that
// they grabbed the right file.
export default class extends Controller {
  static targets = ["input", "preview", "image", "width", "height"]

  preview() {
    const file = this.inputTarget.files?.[0]
    if (!file) return

    this.revoke()
    this.url = URL.createObjectURL(file)
    this.imageTarget.src = this.url
    this.previewTarget.style.display = ""

    // Pass the real proportions along so the portfolio can hang the work at them.
    this.imageTarget.onload = () => this.recordSize()
  }

  recordSize() {
    const { naturalWidth, naturalHeight } = this.imageTarget
    if (!naturalWidth || !naturalHeight) return

    if (this.hasWidthTarget) this.widthTarget.value = naturalWidth
    if (this.hasHeightTarget) this.heightTarget.value = naturalHeight
    this.previewTarget.querySelector(".frame").style.aspectRatio = `${naturalWidth} / ${naturalHeight}`
  }

  disconnect() {
    this.revoke()
  }

  revoke() {
    if (this.url) URL.revokeObjectURL(this.url)
    this.url = null
  }
}

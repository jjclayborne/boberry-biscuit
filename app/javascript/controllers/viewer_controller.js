import { Controller } from "@hotwired/stimulus"

// A work from a project screen, opened big, with the magnifier a catalogue or a
// shopping site gives you: a lens on the picture, and the patch under the lens
// blown up in the pane alongside. The cursor is the whole instrument, so where
// there isn't one -- phones, tablets -- the pane is off and this is just the
// picture, large.

// How far past its size on screen the pane may push the picture. Under the
// floor the magnifier isn't worth the room it takes; over the ceiling even a
// 2000px upload goes to mush.
const MIN_ZOOM = 1.8
const MAX_ZOOM = 3.4

export default class extends Controller {
  static targets = [ "dialog", "stage", "image", "video", "lens", "pane", "zoom", "fig", "name", "meta", "note" ]

  connect() {
    // Going back out of a project screen with the viewer open would leave the
    // wrong work hanging over the page.
    this.onHashChange = () => this.dialogTarget.close()
    window.addEventListener("hashchange", this.onHashChange)

    // Escape, the [close] button and the hash change all end at the dialog's
    // own close event, so that is the one place a playing video has to be put
    // down -- otherwise it keeps running, and talking, behind the page.
    this.onClose = () => this.stopVideo()
    this.dialogTarget.addEventListener("close", this.onClose)
  }

  disconnect() {
    window.removeEventListener("hashchange", this.onHashChange)
    // Disconnect can run while the page is being taken apart, and asking for a
    // target that has already gone raises.
    if (this.hasDialogTarget) this.dialogTarget.removeEventListener("close", this.onClose)
    this.stopVideo()
  }

  // One dialog serves every work; the plate that was clicked says what to hang
  // in it.
  open({ params }) {
    this.figTarget.textContent = params.fig ? `fig. ${params.fig} —` : ""
    this.nameTarget.textContent = params.name || ""
    this.metaTarget.textContent = params.meta ? `· ${params.meta}` : ""
    this.noteTarget.textContent = params.note || ""
    this.noteTarget.hidden = !params.note

    // A video cannot be magnified the way a photograph can -- there is no still
    // to put under a lens -- so it takes the whole stage with its own controls,
    // which is what "see it close up" means for a moving picture.
    this.playing = Boolean(params.video)
    this.stopVideo()
    this.imageTarget.hidden = this.playing
    this.videoTarget.hidden = !this.playing
    this.paneTarget.hidden = this.playing
    this.stageTarget.classList.toggle("showing-video", this.playing)

    // Same URL the plate behind it uses, so the browser has the work already.
    if (this.playing) {
      this.videoTarget.src = params.src
      this.videoTarget.setAttribute("aria-label", params.name || "")
      this.videoTarget.play().catch(() => {})
    } else {
      this.imageTarget.src = params.src
      this.imageTarget.alt = params.name || ""
      this.zoomTarget.src = params.src
    }

    this.rest()
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  // Pausing alone leaves the file buffered and the decoder warm; dropping the
  // source is what actually lets go of it.
  stopVideo() {
    if (!this.hasVideoTarget || !this.videoTarget.getAttribute("src")) return

    this.videoTarget.pause()
    this.videoTarget.removeAttribute("src")
    this.videoTarget.load()
  }

  // Follow the cursor: the patch under it lands in the middle of the pane, and
  // the lens marks that patch on the picture.
  track(event) {
    if (this.playing) return

    const picture = this.pictureRect()
    const pane = this.paneTarget.getBoundingClientRect()
    if (!pane.width || !picture.width) return // no pane to magnify into

    const x = event.clientX - picture.left
    const y = event.clientY - picture.top
    if (x < 0 || y < 0 || x > picture.width || y > picture.height) return this.rest()

    const scale = this.scaleFor(picture)
    const left = this.anchor(pane.width / 2 - x * scale, pane.width, picture.width * scale)
    const top = this.anchor(pane.height / 2 - y * scale, pane.height, picture.height * scale)

    this.zoomTarget.style.width = `${picture.width}px`
    this.zoomTarget.style.transform = `translate(${left}px, ${top}px) scale(${scale})`
    this.zoomTarget.style.visibility = "visible"
    this.paneTarget.classList.add("zooming")

    // Whatever the pane ended up showing is what the lens has to outline.
    this.drawLens(picture, {
      left: -left / scale,
      top: -top / scale,
      width: pane.width / scale,
      height: pane.height / scale
    })
  }

  // Cursor off the picture: lens off, pane back to its invitation.
  rest() {
    this.lensTarget.style.display = "none"
    this.zoomTarget.style.visibility = "hidden"
    this.paneTarget.classList.remove("zooming")
  }

  drawLens(picture, region) {
    const width = Math.min(region.width, picture.width)
    const height = Math.min(region.height, picture.height)

    // The picture is centred in the stage and the lens is positioned against
    // the stage's padding box, which starts inside its border.
    const stage = this.stageTarget.getBoundingClientRect()
    const insetLeft = picture.left - stage.left - this.stageTarget.clientLeft
    const insetTop = picture.top - stage.top - this.stageTarget.clientTop

    this.lensTarget.style.width = `${width}px`
    this.lensTarget.style.height = `${height}px`
    this.lensTarget.style.left = `${insetLeft + clamp(region.left, 0, picture.width - width)}px`
    this.lensTarget.style.top = `${insetTop + clamp(region.top, 0, picture.height - height)}px`
    this.lensTarget.style.display = "block"
  }

  // Life size, where the upload has the pixels for it.
  scaleFor(picture) {
    return clamp(this.imageTarget.naturalWidth / picture.width || MAX_ZOOM, MIN_ZOOM, MAX_ZOOM)
  }

  // Where the picture actually lands inside the stage. The image fills the
  // stage the way every other plate on the site does, so the element is the
  // stage and the picture is letterboxed somewhere inside it -- and it is the
  // picture, not the element, that the lens has to sit on.
  pictureRect() {
    const box = this.imageTarget.getBoundingClientRect()
    const width = this.imageTarget.naturalWidth
    const height = this.imageTarget.naturalHeight
    if (!width || !height) return box

    const shown = Math.min(box.width / width, box.height / height)
    const shownWidth = width * shown
    const shownHeight = height * shown

    return {
      left: box.left + (box.width - shownWidth) / 2,
      top: box.top + (box.height - shownHeight) / 2,
      width: shownWidth,
      height: shownHeight
    }
  }

  // Where the magnified picture sits in the pane: centred on the cursor, but
  // never dragged so far that the pane shows past an edge of it. A picture too
  // small to fill the pane at this magnification just sits in the middle.
  anchor(centred, pane, magnified) {
    const slack = pane - magnified
    return slack >= 0 ? slack / 2 : clamp(centred, slack, 0)
  }
}

function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max)
}

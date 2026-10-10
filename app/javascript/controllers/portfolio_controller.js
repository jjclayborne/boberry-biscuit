import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["screen", "hero", "heroCaption", "peek"]

  connect() {
    this.peekTurns = new Map()
    this.layerOnTop = {}
    this.settleTimers = {}
    this.heroIndex = Math.floor(Math.random() * Math.max(this.heroTargets.length, 1))
    this.renderHero()

    this.onHashChange = () => this.render()
    window.addEventListener("hashchange", this.onHashChange)
    this.render()
  }

  disconnect() {
    window.removeEventListener("hashchange", this.onHashChange)
    clearTimeout(this.leaveTimer)
    Object.values(this.settleTimers).forEach(clearTimeout)
    delete document.body.dataset.yellow
  }

  render() {
    const id = location.hash.replace("#/", "")
    const match = this.screenTargets.find((el) => el.dataset.projectId === id)

    this.screenTargets.forEach((el) => {
      el.style.display = "none"
    })

    const active = match || this.screenTargets.find((el) => !el.dataset.projectId)
    active.style.display = active.dataset.display
    this.clearPeek()
  }

  // Hovering a project link flashes one of its works up in the featured
  // window; each new hover moves on to the project's next work.
  peek({ currentTarget, params: { works } }) {
    if (!this.hasPeekTarget || !Array.isArray(works) || works.length === 0) return

    const turn = this.peekTurns.has(currentTarget)
      ? (this.peekTurns.get(currentTarget) + 1) % works.length
      : Math.floor(Math.random() * works.length)
    this.peekTurns.set(currentTarget, turn)

    clearTimeout(this.leaveTimer)
    const { src, caption } = works[turn]
    this.peeking = src

    // Two layers take turns; the incoming one waits until it has loaded.
    const top = this.layerOnTop.peek
    const layer = top?.getAttribute("src") === src ? top : this.peekTargets.find((el) => el !== top)

    const reveal = () => {
      if (this.peeking !== src) return
      this.dissolve("peek", this.peekTargets, layer)
      this.heroCaptionTarget.textContent = caption
    }

    if (layer.getAttribute("src") !== src) {
      layer.onload = reveal
      layer.src = src
    }
    if (layer.complete && layer.naturalWidth) reveal()
  }

  // A short grace period, so gliding from one link to the next goes straight
  // from picture to picture instead of dipping back to the featured work.
  unpeek() {
    clearTimeout(this.leaveTimer)
    this.leaveTimer = setTimeout(() => this.clearPeek(), 120)
  }

  clearPeek() {
    clearTimeout(this.leaveTimer)
    if (!this.hasPeekTarget || !this.peeking) return

    this.peeking = null
    this.layerOnTop.peek = null
    this.peekTargets.forEach((el) => { el.style.opacity = 0 })
    this.renderHero()
  }

  renderHero() {
    if (!this.hasHeroTarget) return

    const hero = this.heroTargets[this.heroIndex]
    this.heroTargets.forEach((el) => { el.inert = el !== hero })
    this.dissolve("hero", this.heroTargets, hero)
    this.heroCaptionTarget.textContent = hero.dataset.caption
  }

  // Fades `incoming` in on top while whatever it covers stays solid
  // underneath, then clears the rest once it's opaque -- a true crossfade,
  // with nothing from behind showing through halfway.
  dissolve(group, layers, incoming) {
    if (this.layerOnTop[group] !== incoming) {
      incoming.style.transition = "none"
      incoming.style.opacity = 0
      const base = group === "peek" ? 3 : 1
      layers.forEach((el) => { el.style.zIndex = el === incoming ? base + 1 : base })
      incoming.offsetWidth
      incoming.style.transition = ""
      this.layerOnTop[group] = incoming
    }
    incoming.style.opacity = 1

    clearTimeout(this.settleTimers[group])
    this.settleTimers[group] = setTimeout(() => {
      layers.forEach((el) => { if (el !== incoming) el.style.opacity = 0 })
    }, 650)
  }

  shuffleHero() {
    this.heroIndex = (this.heroIndex + 1) % this.heroTargets.length
    this.renderHero()
  }

  goHome() {
    location.hash = ""
  }

  toggleYellow(event) {
    document.body.toggleAttribute("data-yellow", event.target.checked)
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["screen", "hero", "heroCaption"]

  connect() {
    this.heroIndex = Math.floor(Math.random() * Math.max(this.heroTargets.length, 1))
    this.renderHero()

    this.onHashChange = () => this.render()
    window.addEventListener("hashchange", this.onHashChange)
    this.render()
  }

  disconnect() {
    window.removeEventListener("hashchange", this.onHashChange)
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
  }

  renderHero() {
    if (!this.hasHeroTarget) return

    this.heroTargets.forEach((hero, index) => {
      hero.style.display = index === this.heroIndex ? "block" : "none"
    })
    this.heroCaptionTarget.textContent = this.heroTargets[this.heroIndex].dataset.caption
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

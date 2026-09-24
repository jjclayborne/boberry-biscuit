import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["screen", "heroLabel", "heroCaption"]

  heroes = [
    { label: "highlighted image 1", caption: "Hatch Show Print, 2025" },
    { label: "highlighted image 2", caption: "Rites of Passage, 2026" },
    { label: "highlighted image 3", caption: "Musgrave Pencil Co., 2025" },
    { label: "highlighted image 4", caption: "Welcome Fabric, 2026" }
  ]

  connect() {
    this.heroIndex = Math.floor(Math.random() * this.heroes.length)
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
    const hero = this.heroes[this.heroIndex]
    this.heroLabelTarget.textContent = hero.label
    this.heroCaptionTarget.textContent = hero.caption
  }

  shuffleHero() {
    this.heroIndex = (this.heroIndex + 1) % this.heroes.length
    this.renderHero()
  }

  goHome() {
    location.hash = ""
  }

  toggleYellow(event) {
    document.body.toggleAttribute("data-yellow", event.target.checked)
  }
}

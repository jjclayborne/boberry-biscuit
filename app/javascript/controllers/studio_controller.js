import { Controller } from "@hotwired/stimulus"

// Page-level behaviour for the studio: the modals, and the same "yellow?"
// switch the portfolio has.
export default class extends Controller {
  static targets = ["modal"]

  connect() {
    // A form that failed validation comes back with its modal marked open, so
    // the person editing picks up where they left off instead of on a fresh page.
    this.modalTargets
      .filter((modal) => modal.dataset.studioOpen === "true")
      .forEach((modal) => this.showModal(modal))
  }

  open(event) {
    event.preventDefault()
    const modal = this.findModal(event.params.modal || event.currentTarget.dataset.studioModal)
    if (modal) this.showModal(modal)
  }

  close(event) {
    event.preventDefault()
    event.currentTarget.closest("dialog")?.close()
  }

  toggleYellow(event) {
    this.element.toggleAttribute("data-yellow", event.target.checked)
  }

  findModal(id) {
    return this.modalTargets.find((modal) => modal.id === id)
  }

  showModal(modal) {
    modal.showModal()
    modal.querySelector("[autofocus], input:not([type=hidden]), select, textarea")?.focus()
  }
}

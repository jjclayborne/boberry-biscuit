import { Controller } from "@hotwired/stimulus"

// Replaces the browser's "Please fill out this field" bubble, which can't be
// styled, with a note under the field in the studio's own voice. The browser
// still blocks the submit; we only take over how the problem is shown.
export default class extends Controller {
  connect() {
    this.onInvalid = this.invalid.bind(this)
    this.onEdit = this.edit.bind(this)
    this.element.addEventListener("invalid", this.onInvalid, true)
    this.element.addEventListener("input", this.onEdit)
    this.element.addEventListener("change", this.onEdit)
  }

  disconnect() {
    this.element.removeEventListener("invalid", this.onInvalid, true)
    this.element.removeEventListener("input", this.onEdit)
    this.element.removeEventListener("change", this.onEdit)
  }

  invalid(event) {
    event.preventDefault()
    const field = event.target
    this.show(field, this.messageFor(field))

    const first = this.element.querySelector(":invalid")
    if (field === first) field.focus()
  }

  edit(event) {
    const field = event.target
    if (field.validity?.valid) this.clear(field)
  }

  show(field, message) {
    let note = this.noteFor(field)
    if (!note) {
      note = document.createElement("span")
      note.className = "field-error"
      note.id = `${field.id || field.name}-error`
      ;(field.closest(".studio-field") || field.parentElement).append(note)
    }
    note.textContent = message
    field.setAttribute("aria-invalid", "true")
    field.setAttribute("aria-describedby", note.id)
  }

  clear(field) {
    this.noteFor(field)?.remove()
    field.removeAttribute("aria-invalid")
    field.removeAttribute("aria-describedby")
  }

  noteFor(field) {
    const id = field.getAttribute("aria-describedby")
    return id ? document.getElementById(id) : null
  }

  messageFor(field) {
    const v = field.validity
    if (v.valueMissing) {
      if (field.type === "file") return "choose a picture first"
      if (field.tagName === "SELECT") return "pick one from the list"
      return "this one can't be left blank"
    }
    if (v.typeMismatch && field.type === "email") return "that doesn't look like an email address"
    if (v.rangeUnderflow) return `has to be ${field.min} or later`
    if (v.rangeOverflow) return `has to be ${field.max} or earlier`
    if (v.tooLong) return `keep it under ${field.maxLength} characters`
    if (v.badInput || v.stepMismatch) return "that should be a whole number"
    return field.validationMessage.toLowerCase()
  }
}

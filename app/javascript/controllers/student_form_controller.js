import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "name", "counter", "submit", "requiredField" ]

  connect() {
    this.check()
  }

  check() {
    this.updateCount()
    this.validateForm()
  }

  updateCount() {
    if (this.hasNameTarget && this.hasCounterTarget) {
      const length = this.nameTarget.value.length
      this.counterTarget.textContent = `${length} character${length === 1 ? '' : 's'}`
    }
  }

  validateForm() {
    if (!this.hasSubmitTarget) return

    let isValid = true
    this.requiredFieldTargets.forEach(field => {
      if (!field.value.trim()) {
        isValid = false
      }
    })
    this.submitTarget.disabled = !isValid
  }
}

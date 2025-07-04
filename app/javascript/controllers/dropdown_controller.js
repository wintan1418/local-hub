import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.menuTarget.addEventListener("click", (event) => {
      event.stopPropagation()
    })
    
    document.addEventListener("click", this.closeMenu.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.closeMenu.bind(this))
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
  }

  closeMenu() {
    this.menuTarget.classList.add("hidden")
  }
}
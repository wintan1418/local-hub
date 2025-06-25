import { Controller } from "@hotwired/stimulus"

// Toggle mobile menu
export default class extends Controller {
  static targets = ["menu", "button"]
  static classes = ["open"]
  static values = { isOpen: { type: Boolean, default: false } }

  connect() {
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    
    // Initialize ARIA attributes
    this.menuTarget.setAttribute('aria-hidden', 'true')
    this.buttonTarget.setAttribute('aria-expanded', 'false')
    this.buttonTarget.setAttribute('aria-controls', this.menuTarget.id || this.menuTarget.id = `mobile-menu-${Math.random().toString(36).substr(2, 9)}`)
    
    // Make menu focusable when open
    this.menuTarget.inert = true
  }

  disconnect() {
    this.removeEventListeners()
  }

  isOpenValueChanged(isOpen) {
    this.updateMenu()
    
    if (isOpen) {
      this.addEventListeners()
      // Focus first focusable element in the menu
      setTimeout(() => {
        const firstFocusable = this.menuTarget.querySelector('a, button, [tabindex="0"]')
        firstFocusable?.focus()
      }, 100)
    } else {
      this.removeEventListeners()
      // Return focus to the menu button
      this.buttonTarget.focus()
    }
  }

  toggle(event) {
    if (event) event.preventDefault()
    this.isOpenValue = !this.isOpenValue
  }

  close(event) {
    if (event) event.preventDefault()
    this.isOpenValue = false
  }

  updateMenu() {
    if (this.isOpenValue) {
      this.menuTarget.classList.remove("hidden")
      this.menuTarget.classList.add("block")
      this.menuTarget.classList.add(this.openClass)
      this.menuTarget.setAttribute('aria-hidden', 'false')
      this.menuTarget.inert = false
      this.buttonTarget.setAttribute('aria-expanded', 'true')
      this.buttonTarget.querySelector("svg:first-child").classList.add("hidden")
      this.buttonTarget.querySelector("svg:last-child").classList.remove("hidden")
      document.body.classList.add('overflow-hidden', 'md:overflow-auto')
    } else {
      this.menuTarget.classList.remove("block", this.openClass)
      this.menuTarget.classList.add("hidden")
      this.menuTarget.setAttribute('aria-hidden', 'true')
      this.menuTarget.inert = true
      this.buttonTarget.setAttribute('aria-expanded', 'false')
      this.buttonTarget.querySelector("svg:first-child").classList.remove("hidden")
      this.buttonTarget.querySelector("svg:last-child").classList.add("hidden")
      document.body.classList.remove('overflow-hidden', 'md:overflow-auto')
    }
  }

  // Handle clicks outside the menu
  handleClickOutside(event) {
    if (!this.element.contains(event.target) && this.isOpenValue) {
      this.isOpenValue = false
    }
  }

  // Handle keyboard navigation
  handleKeydown(event) {
    if (event.key === 'Escape' && this.isOpenValue) {
      this.isOpenValue = false
    }

    // Trap focus within the menu when open
    if (this.isOpenValue && event.key === 'Tab') {
      const focusableElements = this.menuTarget.querySelectorAll('a, button, [tabindex="0"]')
      const firstElement = focusableElements[0]
      const lastElement = focusableElements[focusableElements.length - 1]

      if (event.shiftKey && document.activeElement === firstElement) {
        event.preventDefault()
        lastElement.focus()
      } else if (!event.shiftKey && document.activeElement === lastElement) {
        event.preventDefault()
        firstElement.focus()
      }
    }
  }

  addEventListeners() {
    document.addEventListener('click', this.boundHandleClickOutside, true)
    document.addEventListener('keydown', this.boundHandleKeydown)
  }

  removeEventListeners() {
    document.removeEventListener('click', this.boundHandleClickOutside, true)
    document.removeEventListener('keydown', this.boundHandleKeydown)
  }
}

import { Controller } from "@hotwired/stimulus"

// Smooth scroll to anchor links
export default class extends Controller {
  static targets = ["link"]
  
  connect() {
    // Add click event listeners to all anchor links with the smooth-scroll class
    this.element.querySelectorAll('a[href^="#"]').forEach(anchor => {
      // Skip if the link is for a different page or has a different behavior
      if (anchor.getAttribute('href') !== '#' && 
          !anchor.getAttribute('href').startsWith('#!') &&
          !anchor.hasAttribute('data-turbo') &&
          !anchor.hasAttribute('data-remote')) {
        anchor.addEventListener('click', this.scrollToAnchor.bind(this))
      }
    })
  }

  scrollToAnchor(event) {
    const targetId = event.currentTarget.getAttribute('href')
    
    // Don't prevent default behavior for external links or links with specific attributes
    if (targetId === '#' || 
        targetId.startsWith('#!') || 
        event.currentTarget.hasAttribute('data-turbo') ||
        event.currentTarget.hasAttribute('data-remote')) {
      return
    }

    event.preventDefault()
    
    const targetElement = document.querySelector(targetId)
    if (targetElement) {
      // Close mobile menu if open
      const mobileMenu = document.querySelector('[data-controller="mobile-menu"]')
      if (mobileMenu && mobileMenu.classList.contains('mobile-menu-open')) {
        const toggleButton = mobileMenu.querySelector('[data-action^="mobile-menu#toggle"]')
        if (toggleButton) toggleButton.click()
      }
      
      // Smooth scroll to the target element
      targetElement.scrollIntoView({
        behavior: 'smooth',
        block: 'start'
      })
      
      // Update URL without adding to history
      history.replaceState(null, null, targetId)
    }
  }
}

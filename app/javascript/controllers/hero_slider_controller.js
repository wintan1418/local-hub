import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide", "dot"]

  connect() {
    this.current = 0
    this.startAutoplay()
  }

  disconnect() {
    this.stopAutoplay()
  }

  goTo(event) {
    this.stopAutoplay()
    const index = parseInt(event.currentTarget.dataset.index)
    this.showSlide(index)
    this.startAutoplay()
  }

  showSlide(index) {
    // Hide current
    this.slideTargets[this.current].classList.remove("opacity-100")
    this.slideTargets[this.current].classList.add("opacity-0")
    this.dotTargets[this.current].classList.remove("bg-white", "w-6")
    this.dotTargets[this.current].classList.add("bg-white/40")

    // Show next
    this.current = index % this.slideTargets.length

    this.slideTargets[this.current].classList.remove("opacity-0")
    this.slideTargets[this.current].classList.add("opacity-100")
    this.dotTargets[this.current].classList.remove("bg-white/40")
    this.dotTargets[this.current].classList.add("bg-white", "w-6")
  }

  next() {
    this.showSlide(this.current + 1)
  }

  startAutoplay() {
    this.interval = setInterval(() => this.next(), 5000)
  }

  stopAutoplay() {
    if (this.interval) clearInterval(this.interval)
  }
}

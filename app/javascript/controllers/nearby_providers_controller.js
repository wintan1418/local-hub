import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["prompt", "loading", "error", "results"]
  static values = { radius: { type: Number, default: 25 } }

  connect() {
    // Show the prompt state by default — user clicks to detect location
    this.showPrompt()
  }

  detect() {
    this.requestLocation()
  }

  requestLocation() {
    if (!navigator.geolocation) {
      this.showError("Geolocation is not supported by your browser.")
      return
    }

    this.showLoading()

    navigator.geolocation.getCurrentPosition(
      (position) => this.fetchProviders(position.coords.latitude, position.coords.longitude),
      (error) => this.handleLocationError(error),
      { enableHighAccuracy: false, timeout: 10000, maximumAge: 300000 }
    )
  }

  async fetchProviders(lat, lng) {
    try {
      const response = await fetch(
        `/api/nearby_providers?lat=${lat}&lng=${lng}&radius=${this.radiusValue}`
      )
      const providers = await response.json()

      if (providers.error || providers.length === 0) {
        this.showError("No providers found within " + this.radiusValue + " miles. Try expanding your search.")
        return
      }

      this.renderProviders(providers)
    } catch (e) {
      this.showError("Could not load nearby providers. Please try again later.")
    }
  }

  renderProviders(providers) {
    this.hideAll()
    this.resultsTarget.classList.remove("hidden")

    const grid = this.resultsTarget.querySelector("[data-nearby-grid]")
    grid.innerHTML = providers.map(p => this.providerCard(p)).join("")
  }

  providerCard(p) {
    const initial = (p.display_name || "?")[0].toUpperCase()
    const avatar = p.profile_picture_url
      ? `<img src="${p.profile_picture_url}" alt="${this.escapeHtml(p.display_name)}" class="w-14 h-14 rounded-2xl object-cover">`
      : `<div class="w-14 h-14 rounded-2xl bg-orange-100 flex items-center justify-center text-lg font-bold text-orange-600">${initial}</div>`

    const stars = Array.from({length: 5}, (_, i) =>
      `<i class="fas fa-star text-xs ${i < Math.round(p.average_rating) ? 'text-amber-400' : 'text-gray-200'}"></i>`
    ).join("")

    const badgeHtml = p.badge
      ? `<span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium" style="background: var(--badge-bg); color: var(--badge-text);">
           <i class="${this.escapeHtml(p.badge.icon)} mr-1"></i>${this.escapeHtml(p.badge.name)}
         </span>`
      : ""

    const badgeColors = p.badge ? this.getBadgeColors(p.badge.color) : {}

    const name = this.escapeHtml(p.business_name || p.display_name)
    const location = this.escapeHtml([p.city, p.state].filter(Boolean).join(", "))

    return `
      <a href="${p.url}" class="group block bg-white rounded-2xl border border-gray-100 p-5 hover:shadow-lg hover:border-gray-200 transition-all duration-200"
         ${p.badge ? `style="--badge-bg: ${badgeColors.bg}; --badge-text: ${badgeColors.text};"` : ""}>
        <div class="flex items-start gap-4">
          <div class="flex-shrink-0">${avatar}</div>
          <div class="flex-1 min-w-0">
            <h4 class="font-semibold text-gray-900 group-hover:text-orange-600 transition-colors truncate text-sm">
              ${name}
            </h4>
            <div class="flex items-center gap-1 mt-1">
              ${stars}
              <span class="text-xs text-gray-400 ml-1">${p.average_rating}</span>
            </div>
            <div class="flex items-center gap-3 mt-2 text-xs text-gray-500">
              <span><i class="fas fa-location-dot text-orange-400 mr-1"></i>${p.distance} mi</span>
              <span><i class="fas fa-check-circle text-green-400 mr-1"></i>${p.total_completed_bookings} jobs</span>
            </div>
            ${badgeHtml ? `<div class="mt-2">${badgeHtml}</div>` : ""}
          </div>
        </div>
      </a>
    `
  }

  getBadgeColors(color) {
    const map = {
      purple: { bg: "#faf5ff", text: "#7e22ce" },
      blue:   { bg: "#eff6ff", text: "#1d4ed8" },
      green:  { bg: "#f0fdf4", text: "#15803d" },
      yellow: { bg: "#fefce8", text: "#a16207" },
      gray:   { bg: "#f9fafb", text: "#6b7280" }
    }
    return map[color] || map.gray
  }

  hideAll() {
    if (this.hasPromptTarget) this.promptTarget.classList.add("hidden")
    this.loadingTarget.classList.add("hidden")
    this.errorTarget.classList.add("hidden")
    this.resultsTarget.classList.add("hidden")
  }

  showPrompt() {
    this.hideAll()
    if (this.hasPromptTarget) this.promptTarget.classList.remove("hidden")
  }

  showLoading() {
    this.hideAll()
    this.loadingTarget.classList.remove("hidden")
  }

  showError(message) {
    this.hideAll()
    this.errorTarget.classList.remove("hidden")
    this.errorTarget.querySelector("[data-error-message]").textContent = message
  }

  handleLocationError(error) {
    const messages = {
      1: "Location access was denied. Enable location in your browser to see nearby providers.",
      2: "Could not determine your location. Please try again.",
      3: "Location request timed out. Please try again."
    }
    this.showError(messages[error.code] || "Could not get your location.")
  }

  retry() {
    this.requestLocation()
  }

  escapeHtml(str) {
    if (!str) return ""
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
  }
}

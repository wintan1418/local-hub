import { Controller } from "@hotwired/stimulus"

// Dismissable alerts and notifications
export default class extends Controller {
  // Dismiss the alert by removing the parent element
  dismiss() {
    this.element.remove();
  }
  
  // Auto-dismiss after a delay (if data-delay is set)
  connect() {
    const delay = this.data.get("delay");
    if (delay) {
      setTimeout(() => {
        this.dismiss();
      }, parseInt(delay));
    }
  }
}

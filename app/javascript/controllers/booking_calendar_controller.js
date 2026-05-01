import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.setNativeDateTimeFallback()

    import("flatpickr")
      .then(({ default: flatpickr }) => {
        this.initializeFlatpickr(flatpickr)
      })
      .catch(() => {
        this.setNativeDateTimeFallback()
      })
  }

  initializeFlatpickr(flatpickr) {
    if (!this.element.isConnected) return

    try {
      this.flatpickr = flatpickr(this.element, {
        enableTime: true,
        dateFormat: "Y-m-d H:i",
        minDate: "today",
        time_24hr: true,
        minuteIncrement: 30,
        defaultHour: 9,
        defaultMinute: 0
      });

      this.element.style.cursor = "pointer";
    } catch (error) {
      this.setNativeDateTimeFallback()
    }
  }

  setNativeDateTimeFallback() {
    this.element.type = "datetime-local";
    this.element.readOnly = false;
    this.element.style.cursor = "pointer";

    const today = new Date();
    this.element.min = today.toISOString().slice(0, 16);
  }

  disconnect() {
    if (this.flatpickr) {
      this.flatpickr.destroy();
    }
  }
}

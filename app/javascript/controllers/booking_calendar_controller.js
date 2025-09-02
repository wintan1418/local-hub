import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  connect() {
    console.log("Booking calendar controller connected!");
    
    // Simple fallback first - if flatpickr doesn't work, use native datetime
    if (typeof flatpickr === 'undefined') {
      console.log("Flatpickr not available, using native datetime input");
      this.element.type = "datetime-local";
      this.element.readOnly = false;
      this.element.style.cursor = "pointer";
      
      // Set minimum date to today
      const today = new Date();
      const minDateTime = today.toISOString().slice(0, 16);
      this.element.min = minDateTime;
      return;
    }

    // Try to initialize Flatpickr
    try {
      console.log("Initializing Flatpickr...");
      this.flatpickr = flatpickr(this.element, {
        enableTime: true,
        dateFormat: "Y-m-d H:i",
        minDate: "today",
        time_24hr: true,
        minuteIncrement: 30,
        defaultHour: 9,
        defaultMinute: 0,
        onReady: (selectedDates, dateStr, instance) => {
          console.log("Flatpickr calendar is ready!");
        },
        onChange: (selectedDates, dateStr, instance) => {
          console.log("Date selected:", dateStr);
        }
      });
      
      // Make sure the element is clickable
      this.element.style.cursor = "pointer";
      
    } catch (error) {
      console.error("Flatpickr initialization failed:", error);
      // Fallback to native datetime input
      this.element.type = "datetime-local";
      this.element.readOnly = false;
      this.element.style.cursor = "pointer";
      
      const today = new Date();
      const minDateTime = today.toISOString().slice(0, 16);
      this.element.min = minDateTime;
    }
  }

  disconnect() {
    if (this.flatpickr) {
      this.flatpickr.destroy();
    }
  }
} 
// Import all the channels to be used by Action Cable
import consumer from "./consumer"

// Make ActionCable consumer available globally
window.App = window.App || {};
window.App.cable = consumer;

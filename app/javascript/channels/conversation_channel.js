import consumer from "./consumer"

// Make App global so we can access it from views
window.App = window.App || {};
window.App.cable = consumer;

import consumer from "./consumer"

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    console.log("NotificationsChannel connected")
  },

  disconnected() {},

  received(data) {
    // Update notification badge count
    var badges = document.querySelectorAll('[data-notification-count]')
    badges.forEach(function(el) {
      el.textContent = data.unread_count > 9 ? '9+' : data.unread_count
      el.classList.remove('hidden')
    })

    // Show toast
    showNotificationToast(data)
  }
})

function showNotificationToast(data) {
  var toast = document.createElement('div')
  toast.className = 'fixed top-20 right-4 z-[100] max-w-sm bg-white rounded-xl shadow-2xl border border-slate-100 p-4 animate-slide-in-right'
  toast.innerHTML = `
    <div class="flex items-start gap-3">
      <div class="w-9 h-9 rounded-lg bg-orange-50 flex items-center justify-center flex-shrink-0">
        <i class="${data.icon || 'fas fa-bell text-orange-500'} text-sm"></i>
      </div>
      <div class="flex-1 min-w-0">
        <div class="text-sm font-bold text-slate-900">${escapeHtml(data.title)}</div>
        <div class="text-xs text-slate-500 mt-0.5 line-clamp-2">${escapeHtml(data.message)}</div>
      </div>
      <button onclick="this.closest('.fixed').remove()" class="text-slate-300 hover:text-slate-600 flex-shrink-0">
        <i class="fas fa-times text-xs"></i>
      </button>
    </div>
  `
  document.body.appendChild(toast)
  setTimeout(function() {
    toast.style.transition = 'all 0.3s'
    toast.style.opacity = '0'
    toast.style.transform = 'translateX(120%)'
    setTimeout(function() { toast.remove() }, 300)
  }, 5000)
}

function escapeHtml(str) {
  var div = document.createElement('div')
  div.textContent = str || ''
  return div.innerHTML
}

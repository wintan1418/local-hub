import consumer from "./consumer"

// Make App global so we can access it from views
window.App = window.App || {};
window.App.cable = consumer;

// Define the ConversationChannel class for dynamic subscription creation
window.App.ConversationChannel = {
  subscribe: function(conversationId) {
    return consumer.subscriptions.create({
      channel: "ConversationChannel",
      conversation_id: conversationId
    }, {
      received: function(data) {
        if (data.typing !== undefined) {
          // Handle typing indicator
          const typingIndicator = document.getElementById('typing-indicator');
          const typingUser = document.getElementById('typing-user');
          
          if (data.typing && data.sender_id !== window.currentUserId) {
            if (typingUser) typingUser.textContent = data.sender_name;
            if (typingIndicator) typingIndicator.classList.remove('hidden');
          } else if (!data.typing) {
            if (typingIndicator) typingIndicator.classList.add('hidden');
          }
        } else if (data.sender_id !== window.currentUserId) {
          // Handle incoming message
          const messagesContainer = document.getElementById('messages-container');
          if (messagesContainer) {
            messagesContainer.insertAdjacentHTML('beforeend', data.message);
            messagesContainer.scrollTop = messagesContainer.scrollHeight;
          }
        }
      },
      
      speak: function(data) {
        this.perform('speak', data);
        
        // Add message optimistically
        const messagesContainer = document.getElementById('messages-container');
        if (messagesContainer) {
          const messageHtml = `
            <div class="flex justify-end mb-3">
              <div class="max-w-xs lg:max-w-md px-4 py-2 rounded-lg bg-blue-600 text-white rounded-br-sm relative">
                <p class="text-sm whitespace-pre-wrap">${data.content}</p>
                <div class="flex items-center justify-end mt-1 space-x-1">
                  <p class="text-xs text-blue-100">Just now</p>
                  <div class="text-blue-100 text-xs">
                    <i class="fas fa-check"></i>
                  </div>
                </div>
              </div>
            </div>
          `;
          messagesContainer.insertAdjacentHTML('beforeend', messageHtml);
          messagesContainer.scrollTop = messagesContainer.scrollHeight;
        }
      },
      
      startTyping: function() {
        this.perform('start_typing');
      },
      
      stopTyping: function() {
        this.perform('stop_typing');
      }
    });
  }
};

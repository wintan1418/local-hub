// Custom Tailwind plugin to fix container queries
const plugin = require('tailwindcss/plugin')

module.exports = plugin(function({ addComponents, theme }) {
  const screens = theme('screens', {})
  const container = {
    '.container': {
      width: '100%',
      marginLeft: 'auto',
      marginRight: 'auto',
      paddingLeft: theme('spacing.4'),
      paddingRight: theme('spacing.4'),
    },
  }

  // Add responsive container sizes
  Object.entries(screens).forEach(([screen, value]) => {
    container['@media (min-width: ' + value + ')'] = {
      '.container': {
        maxWidth: value,
      },
    }
  })

  addComponents(container)
})

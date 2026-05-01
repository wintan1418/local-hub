const defaultTheme = require('tailwindcss/defaultTheme')
const containerPlugin = require('./initializers/tailwind_container_plugin')

module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js',
    './app/components/**/*.rb',
    './app/components/**/*.html.erb'
  ],
  theme: {
    screens: {
      'sm': '640px',
      'md': '768px',
      'lg': '1024px',
      'xl': '1280px',
      '2xl': '1536px',
    },
    extend: {
      fontFamily: {
        display: ['Fraunces', 'ui-serif', 'Georgia', 'serif'],
        sans: ['Inter var', 'Inter', ...defaultTheme.fontFamily.sans],
        mono: ['JetBrains Mono', ...defaultTheme.fontFamily.mono],
      },
      borderRadius: {
        pill: '999px',
      },
      colors: {
        cream: '#f3ead8',
        'cream-elevated': '#fdf8ed',
        'cream-sunken': '#e6d8bf',
        ink: '#1d1813',
        'ink-2': '#3d3327',
        'ink-3': '#514637',
        'ink-4': '#7c6b52',
        line: '#ddc9a8',
        'line-strong': '#c4ab85',
        forest: '#1f4d3a',
        'forest-soft': '#dce5d4',
        terracotta: '#d96a3a',
        clay: '#b8551c',
        primary: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c4a6e',
        },
      },
      boxShadow: {
        card: '0 1px 2px rgba(26,26,23,0.04), 0 1px 1px rgba(26,26,23,0.03)',
        'card-md': '0 4px 16px rgba(26,26,23,0.06), 0 1px 2px rgba(26,26,23,0.04)',
        'card-lg': '0 12px 40px rgba(26,26,23,0.08), 0 2px 6px rgba(26,26,23,0.04)',
        'card-hover': '0 10px 15px -3px rgb(0 0 0 / 0.08), 0 4px 6px -4px rgb(0 0 0 / 0.04)',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    containerPlugin
  ],
  // Disable modern features that might cause issues
  future: {
    hoverOnlyWhenSupported: false,
  },
  experimental: {
    legacyVariableNames: true
  },
  // Add this to fix CSS compilation issues
  corePlugins: {
    preflight: true,
  }
}

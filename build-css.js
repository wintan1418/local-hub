const fs = require('fs');
const postcss = require('postcss');
const tailwindcss = require('tailwindcss');
const autoprefixer = require('autoprefixer');

// Process the CSS with PostCSS and Tailwind
async function buildCSS() {
  const input = './app/assets/stylesheets/tailwind.css';
  const output = './app/assets/builds/tailwind.css';

  // Ensure the builds directory exists
  if (!fs.existsSync('./app/assets/builds')) {
    fs.mkdirSync('./app/assets/builds', { recursive: true });
  }

  // Read the input CSS
  const css = fs.readFileSync(input, 'utf8');

  // Process the CSS with PostCSS and Tailwind
  const result = await postcss([
    tailwindcss(),
    autoprefixer(),
    // Add a plugin to fix media queries
    (root) => {
      root.walkAtRules('media', (atRule) => {
        // Convert modern media query syntax to traditional syntax
        atRule.params = atRule.params
          .replace(/\(width\s*>=\s*([^)]+)\)/g, '(min-width: $1)')
          .replace(/\(width\s*<=\s*([^)]+)\)/g, '(max-width: $1)')
          .replace(/\(width\s*=\s*([^)]+)\)/g, '(width: $1)');
      });
    },
  ]).process(css, {
    from: input,
    to: output,
    map: { inline: false },
  });

  // Write the processed CSS to the output file
  fs.writeFileSync(output, result.css, 'utf8');
  if (result.map) {
    fs.writeFileSync(`${output}.map`, result.map.toString(), 'utf8');
  }

  console.log('Tailwind CSS built successfully!');
}

// Run the build
buildCSS().catch((error) => {
  console.error('Error building CSS:', error);
  process.exit(1);
});

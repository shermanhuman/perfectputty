const fs = require('fs');
const path = require('path');

// Convert color scheme to Starship colors
function convertColorsToStarship(colorScheme) {
  return {
    // Map color scheme colors to Starship palette
    black: colorScheme.colors.black,
    red: colorScheme.colors.red,
    green: colorScheme.colors.green,
    yellow: colorScheme.colors.yellow,
    blue: colorScheme.colors.blue,
    purple: colorScheme.colors.purple,
    cyan: colorScheme.colors.cyan,
    white: colorScheme.colors.white,
    'bright-black': colorScheme.colors.brightBlack,
    'bright-red': colorScheme.colors.brightRed,
    'bright-green': colorScheme.colors.brightGreen,
    'bright-yellow': colorScheme.colors.brightYellow,
    'bright-blue': colorScheme.colors.brightBlue,
    'bright-purple': colorScheme.colors.brightPurple,
    'bright-cyan': colorScheme.colors.brightCyan,
    'bright-white': colorScheme.colors.brightWhite
  };
}

// Process template with color scheme
function processTemplate(templateContent, colorScheme) {
  // Convert color scheme to Starship palette
  const palette = convertColorsToStarship(colorScheme);
  
  // Replace color placeholders in template
  let processedContent = templateContent;
  
  // Add palette definition
  const paletteSection = `
# Color palette based on ${colorScheme.name}
palette = "perfect"

[palettes.perfect]
black = "${palette.black}"
red = "${palette.red}"
green = "${palette.green}"
yellow = "${palette.yellow}"
blue = "${palette.blue}"
purple = "${palette.purple}"
cyan = "${palette.cyan}"
white = "${palette.white}"
bright-black = "${palette['bright-black']}"
bright-red = "${palette['bright-red']}"
bright-green = "${palette['bright-green']}"
bright-yellow = "${palette['bright-yellow']}"
bright-blue = "${palette['bright-blue']}"
bright-purple = "${palette['bright-purple']}"
bright-cyan = "${palette['bright-cyan']}"
bright-white = "${palette['bright-white']}"
`;
  
  // Replace palette placeholder
  processedContent = processedContent.replace('# PALETTE_PLACEHOLDER #', paletteSection);
  
  return processedContent;
}

// Build Starship themes
async function buildStarshipThemes(userConfig, colorScheme, distDir) {
  console.log('Building Starship themes...');
  
  console.log(`Using color scheme: ${colorScheme.name}`);
  
  // Get template files
  const shellThemesDir = path.join(process.cwd(), 'core', 'shell-themes');
  
  // Create output directory in dist
  const outputDir = path.join(distDir, 'shell-themes');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }
  
  // Process each template
  const templateFiles = fs.readdirSync(shellThemesDir)
    .filter(file => file.endsWith('.tmpl'));
  
  for (const templateFile of templateFiles) {
    const templatePath = path.join(shellThemesDir, templateFile);
    const templateContent = fs.readFileSync(templatePath, 'utf8');
    
    // Get theme name from filename (e.g., perfect.toml.tmpl -> perfect)
    const themeName = path.basename(templateFile, '.toml.tmpl');
    
    // Skip if not the selected theme
    if (themeName !== userConfig.shell.theme) {
      continue;
    }
    
    console.log(`Processing theme: ${themeName}`);
    
    // Process template with color scheme
    const processedContent = processTemplate(templateContent, colorScheme);
    
    // Write processed template to output file
    const outputPath = path.join(outputDir, `${themeName}.toml`);
    fs.writeFileSync(outputPath, processedContent);
    
    console.log(`Generated: ${outputPath}`);
  }
}

module.exports = { buildStarshipThemes };